module TCXReader

using EzXML, CSV, DataFrames, Dates, Statistics

export TCXTrackPoint, BuildVersion, TCXAuthor, TCXLap, TCXActivity, DeviceInfo, loadTCXFile, parseTCXAuthor, parseTCXLap, parseTCXTrackPoint, parseDeviceInfo, exportCSV, calculate_averages_and_totals

include("TCXTrackPoint.jl")
include("TCXAuthor.jl")
include("TCXLap.jl")
include("TCXActivity.jl")

const NS_MAP = Dict(
    "g" => "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2",
    "ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2"
)

"""
    parseOptionalFloat(node, path)

Parse an optional float value from an XML node. If the value is not found, return `nothing`.

# Arguments
- `node`: The XML node to search within.
- `path`: The XPath string to locate the desired value.

# Returns
- `Float64` value if found, otherwise `nothing`.
"""
function parseOptionalFloat(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? parse(Float64, nodecontent(valueNode)) : nothing
end

"""
    parseOptionalInt(node, path)

Parse an optional integer value from an XML node. If the value is not found, return `nothing`.

# Arguments
- `node`: The XML node to search within.
- `path`: The XPath string to locate the desired value.

# Returns
- `Int` value if found, otherwise `nothing`.
"""
function parseOptionalInt(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? parse(Int, nodecontent(valueNode)) : nothing
end

"""
    parseOptionalString(node, path)

Parse an optional string value from an XML node. If the value is not found, return an empty string.

# Arguments
- `node`: The XML node to search within.
- `path`: The XPath string to locate the desired value.

# Returns
- `String` value if found, otherwise an empty string.
"""
function parseOptionalString(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? nodecontent(valueNode) : ""
end

"""
    parseDateTime(timeStr::String) -> DateTime

Parse an ISO-8601 timestamp. Fractional seconds are optional and may contain any
number of digits; precision finer than milliseconds is truncated to match
`DateTime`. A trailing `Z` or a `±HH:MM` offset is accepted, with offsets
normalized to UTC. A timestamp without an offset is treated as UTC. An empty
string returns the sentinel `DateTime(1, 1, 1)`.

Malformed non-empty timestamps throw `ArgumentError`.
"""
function parseDateTime(timeStr::String)
    value = strip(timeStr)
    isempty(value) && return DateTime(1, 1, 1)

    parsed = match(
        r"^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(?:\.(\d+))?([zZ]|[+-]\d{2}:\d{2})?$",
        value,
    )
    parsed === nothing && throw(ArgumentError("invalid ISO-8601 timestamp: $timeStr"))

    timestamp = DateTime(
        string(parsed.captures[1], "T", parsed.captures[2]),
        dateformat"yyyy-mm-ddTHH:MM:SS",
    )

    fraction = parsed.captures[3]
    if fraction !== nothing
        milliseconds = parse(Int, rpad(first(fraction, min(length(fraction), 3)), 3, '0'))
        timestamp += Millisecond(milliseconds)
    end

    timezone = parsed.captures[4]
    if timezone !== nothing && lowercase(timezone) != "z"
        offset_hours = parse(Int, timezone[2:3])
        offset_minutes = parse(Int, timezone[5:6])
        if offset_hours > 14 || offset_minutes > 59 || (offset_hours == 14 && offset_minutes != 0)
            throw(ArgumentError("invalid UTC offset in timestamp: $timeStr"))
        end

        direction = startswith(timezone, "+") ? 1 : -1
        timestamp -= Minute(direction * (60 * offset_hours + offset_minutes))
    end

    return timestamp
end

"""
    parseTCXLap(node::EzXML.Node) -> TCXLap

Parse a TCX `Lap` node. Missing start time, total time, distance, and
calories use the existing `TCXLap` constructor defaults. Optional measurements
remain `nothing`; malformed present numeric values throw an error. Malformed
trackpoints are omitted according to [`parseTCXTrackPoint`](@ref).
"""
function parseTCXLap(node::EzXML.Node)::TCXLap
    startTime = haskey(node, "StartTime") ? parseDateTime(node["StartTime"]) : DateTime(1, 1, 1)
    totalTimeSeconds = something(parseOptionalFloat(node, "./g:TotalTimeSeconds"), 0.0)
    distanceMeters = something(parseOptionalFloat(node, "./g:DistanceMeters"), 0.0)
    maximumSpeed = parseOptionalFloat(node, "./g:MaximumSpeed")
    calories = something(parseOptionalInt(node, "./g:Calories"), 0)
    averageHeartRateBpm = parseOptionalInt(node, "./g:AverageHeartRateBpm/g:Value")
    maximumHeartRateBpm = parseOptionalInt(node, "./g:MaximumHeartRateBpm/g:Value")
    intensity = parseOptionalString(node, "./g:Intensity")
    cadence = parseOptionalInt(node, "./g:Cadence")
    triggerMethod = parseOptionalString(node, "./g:TriggerMethod")
    avgSpeed = parseOptionalFloat(node, ".//ns3:LX/ns3:AvgSpeed")

    trackpoint_nodes = findall(".//g:Trackpoint", node, NS_MAP)
    trackPoints = TCXTrackPoint[
        trackpoint for trackpoint in (parseTCXTrackPoint(trackpoint_node) for trackpoint_node in trackpoint_nodes)
        if trackpoint !== nothing
    ]

    return TCXLap(startTime, totalTimeSeconds=totalTimeSeconds, distanceMeters=distanceMeters, maximumSpeed=maximumSpeed,
        calories=calories, averageHeartRateBpm=averageHeartRateBpm, maximumHeartRateBpm=maximumHeartRateBpm,
        intensity=intensity, cadence=cadence, trackPoints=trackPoints, triggerMethod=triggerMethod, avgSpeed=avgSpeed)
end

"""
    parseTCXTrackPoint(node::EzXML.Node) -> Union{TCXTrackPoint, Nothing}

Parse a TCX `Trackpoint` node, including speed and power stored in separate
activity-extension `TPX` elements. Missing optional measurements become
`nothing`. If the timestamp or a present value is malformed, emit a warning
and return `nothing` so callers can skip that point.
"""
function parseTCXTrackPoint(node::EzXML.Node)::Union{TCXTrackPoint, Nothing}
    try
        time_node = findfirst(".//g:Time", node, NS_MAP)
        time_node === nothing && throw(ArgumentError("trackpoint is missing Time"))
        time = parseDateTime(nodecontent(time_node))

        latitude = parseOptionalFloat(node, ".//g:Position/g:LatitudeDegrees")
        longitude = parseOptionalFloat(node, ".//g:Position/g:LongitudeDegrees")

        altitude_meters = parseOptionalFloat(node, ".//g:AltitudeMeters")
        distance_meters = parseOptionalFloat(node, ".//g:DistanceMeters")

        heart_rate_bpm = parseOptionalInt(node, ".//g:HeartRateBpm/g:Value")

        cadence = parseOptionalInt(node, ".//g:Cadence")

        tpx_nodes = findall(".//ns3:TPX", node, NS_MAP)
        speed = parseOptionalFloat(node, ".//ns3:TPX/ns3:Speed")
        watts = parseOptionalInt(node, ".//ns3:TPX/ns3:Watts")

        if isempty(tpx_nodes)
            @debug "No <ns3:TPX> extension found at time $time."
        end

        return TCXTrackPoint(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, cadence, speed, watts)

    catch e
        @warn "Error parsing trackpoint: $e. Skipping this trackpoint."
        return nothing
    end
end

"""
    parseBuildVersion(node::EzXML.Node)

Parse a build version node into a `BuildVersion` object.

# Arguments
- `node`: The XML node representing the build version.

# Returns
- `BuildVersion` object.
"""
function parseBuildVersion(node::EzXML.Node)::BuildVersion
    versionMajor = something(parseOptionalInt(node, ".//g:VersionMajor"), 0)
    versionMinor = something(parseOptionalInt(node, ".//g:VersionMinor"), 0)
    buildMajor = something(parseOptionalInt(node, ".//g:BuildMajor"), 0)
    buildMinor = something(parseOptionalInt(node, ".//g:BuildMinor"), 0)

    return BuildVersion(versionMajor, versionMinor, buildMajor, buildMinor)
end

"""
    parseTCXAuthor(doc::EzXML.Document) -> TCXAuthor

Parse document-level author metadata. A missing author or missing author fields
use `TCXAuthor()` and `BuildVersion()` defaults; malformed present version
numbers throw an error.
"""
function parseTCXAuthor(doc::EzXML.Document)::TCXAuthor
    authorNode = findfirst(".//g:Author", doc.root, NS_MAP)

    if authorNode !== nothing
        name = parseOptionalString(authorNode, "./g:Name")
        buildNode = findfirst(".//g:Build", authorNode, NS_MAP)
        build = buildNode !== nothing ? parseBuildVersion(buildNode) : BuildVersion()
        langID = parseOptionalString(authorNode, "./g:LangID")
        partNumber = parseOptionalString(authorNode, "./g:PartNumber")

        return TCXAuthor(name, build, langID, partNumber)
    else
        return TCXAuthor()
    end
end

function _parseDeviceInfo(creatorNode::Union{EzXML.Node, Nothing})::DeviceInfo
    if creatorNode !== nothing
        name = parseOptionalString(creatorNode, "./g:Name")
        unitId = parseOptionalString(creatorNode, "./g:UnitId")
        productId = something(parseOptionalInt(creatorNode, "./g:ProductID"), 0)
        versionMajor = parseOptionalInt(creatorNode, ".//g:Version/g:VersionMajor")
        versionMinor = parseOptionalInt(creatorNode, ".//g:Version/g:VersionMinor")
        version = versionMajor !== nothing && versionMinor !== nothing ? "$versionMajor.$versionMinor" : ""
        return DeviceInfo(name, unitId, productId, version)
    else
        return DeviceInfo()
    end
end

"""
    parseDeviceInfo(doc::EzXML.Document) -> DeviceInfo

Parse the first activity creator in `doc`. Missing creator fields use the
`DeviceInfo()` defaults; a present but invalid numeric field throws an error.
`loadTCXFile` parses creators per activity, while this document-level method is
retained for compatibility.
"""
function parseDeviceInfo(doc::EzXML.Document)::DeviceInfo
    return _parseDeviceInfo(findfirst(".//g:Creator", doc.root, NS_MAP))
end

"""
    exportCSV(author::TCXAuthor, activities::Vector{TCXActivity}, csv_filepath::String; io=stdout)

Export parsed TCX trackpoints to a CSV file. Each row represents one
trackpoint; laps without trackpoints therefore produce no rows. The existing
column order and missing-value representation are preserved. A completion
message is written to `io`.

# Arguments
- `author`: The `TCXAuthor` object containing author information.
- `activities`: A vector of `TCXActivity` objects representing the activities.
- `csv_filepath`: The file path where the CSV file will be saved.
- `io`: The stream used for the completion message.
"""
function exportCSV(
    author::TCXAuthor,
    activities::Vector{TCXActivity},
    csv_filepath::String;
    io::IO=stdout,
)
    df = DataFrame(
        AuthorName = String[],
        AuthorBuildVersion = String[],
        AuthorLangID = String[],
        AuthorPartNumber = String[],
        ActivitySport = String[],
        ActivityID = String[],
        DeviceName = String[],
        DeviceVersion = String[],
        LapNumber = Int[],
        StartTime = String[],
        TotalTimeSeconds = Float64[],
        DistanceMeters = Float64[],
        Calories = Int[],
        AverageHR = Union{Int, Missing}[],
        MaximumHR = Union{Int, Missing}[],
        Intensity = String[],
        TrackPointTime = String[],
        Latitude = Union{Float64, Missing}[],
        Longitude = Union{Float64, Missing}[],
        AltitudeMeters = Union{Float64, Missing}[],
        DistanceMetersTP = Union{Float64, Missing}[],
        HeartRateBpm = Union{Int, Missing}[],
        Cadence = Union{Int, Missing}[],
        Speed = Union{Float64, Missing}[],
        Watts = Union{Int, Missing}[]
    )

    for activity in activities
        for (lap_num, lap) in enumerate(activity.laps)
            for tp in lap.trackPoints
                row = (
                    author.name,
                    string(author.build.versionMajor, ".", author.build.versionMinor),
                    author.langID,
                    author.partNumber,
                    activity.sport,
                    string(activity.id),
                    activity.device.name,
                    activity.device.version,
                    lap_num,
                    string(lap.startTime),
                    lap.totalTimeSeconds,
                    lap.distanceMeters,
                    lap.calories,
                    lap.averageHeartRateBpm === nothing ? missing : lap.averageHeartRateBpm,
                    lap.maximumHeartRateBpm === nothing ? missing : lap.maximumHeartRateBpm,
                    lap.intensity,
                    string(tp.time),
                    tp.latitude === nothing ? missing : tp.latitude,
                    tp.longitude === nothing ? missing : tp.longitude,
                    tp.altitude_meters === nothing ? missing : tp.altitude_meters,
                    tp.distance_meters === nothing ? missing : tp.distance_meters,
                    tp.heart_rate_bpm === nothing ? missing : tp.heart_rate_bpm,
                    tp.cadence === nothing ? missing : tp.cadence,
                    tp.speed === nothing ? missing : tp.speed,
                    tp.watts === nothing ? missing : tp.watts
                )
                push!(df, row)
            end
        end
    end

    CSV.write(csv_filepath, df; header=true)
    println(io, "Exported complete TCX data to $csv_filepath")
end

"""
    calculate_averages_and_totals(lap_data::Vector{TCXLap}) -> Tuple

Calculate activity totals and unweighted trackpoint statistics. The returned
16-tuple is ordered as:

`(total_time, total_distance, max_speed, total_calories, avg_hr, max_hr,
avg_cadence_zero_avg_on, avg_cadence_zero_avg_off, max_cadence, avg_speed,
total_ascent, total_descent, max_altitude, avg_watts_zero_avg_on,
avg_watts_zero_avg_off, max_watts)`.

Missing cadence and power count as zero in the corresponding "zero averaging
off" values. Speed uses trackpoint speed rather than lap-level speed fields,
and elevation changes bridge missing samples and lap boundaries. Empty inputs
return lap totals with zero for all trackpoint-derived metrics.
"""
function calculate_averages_and_totals(lap_data::Vector{TCXLap})

    total_time = sum([lap.totalTimeSeconds !== nothing ? lap.totalTimeSeconds : 0 for lap in lap_data])
    total_distance = sum([lap.distanceMeters !== nothing ? lap.distanceMeters : 0 for lap in lap_data])
    total_calories = sum([lap.calories !== nothing ? lap.calories : 0 for lap in lap_data]) |> Float64

    trackpoints = vcat([lap.trackPoints for lap in lap_data]...)

    if isempty(trackpoints)
        return (
            total_time, total_distance, 0.0, total_calories, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        )
    end

    hr_values = filter(hr -> hr !== nothing, [tp.heart_rate_bpm for tp in trackpoints])
    avg_hr = isempty(hr_values) ? 0.0 : mean(hr_values) |> Float64

    speed_values = filter(speed -> speed !== nothing, [tp.speed for tp in trackpoints])
    max_speed = isempty(speed_values) ? 0.0 : maximum(speed_values) |> Float64

    max_hr = isempty(hr_values) ? 0.0 : maximum(hr_values) |> Float64

    cadence_values_zero_on = filter(cadence -> cadence > 0, [tp.cadence for tp in trackpoints if tp.cadence !== nothing])
    avg_cadence_zero_avg_on = isempty(cadence_values_zero_on) ? 0.0 : mean(cadence_values_zero_on)

    cadence_values = [tp.cadence !== nothing ? tp.cadence : 0 for tp in trackpoints]
    avg_cadence_zero_avg_off = mean(cadence_values) |> Float64

    max_cadence = isempty(cadence_values_zero_on) ? 0 : maximum(cadence_values_zero_on) |> Int

    avg_speed = isempty(speed_values) ? 0.0 : mean(speed_values)

    altitude_values = filter(alt -> alt !== nothing, [tp.altitude_meters for tp in trackpoints])
    max_altitude = isempty(altitude_values) ? 0.0 : maximum(altitude_values)

    ascent = 0.0
    descent = 0.0

    for i in 2:length(altitude_values)
        alt_diff = altitude_values[i] - altitude_values[i - 1]
        if alt_diff > 0
            ascent += alt_diff
        else
            descent += abs(alt_diff)
        end
    end

    watts_values_zero_on = filter(watts -> watts > 0, [tp.watts for tp in trackpoints if tp.watts !== nothing])
    avg_watts_zero_avg_on = isempty(watts_values_zero_on) ? 0.0 : mean(watts_values_zero_on)

    watts_values = [tp.watts !== nothing ? tp.watts : 0 for tp in trackpoints]
    avg_watts_zero_avg_off = mean(watts_values) |> Float64

    max_watts = isempty(watts_values_zero_on) ? 0.0 : maximum(watts_values_zero_on) |> Float64

    return (
        total_time,
        total_distance,
        max_speed,
        total_calories,
        avg_hr,
        max_hr,
        avg_cadence_zero_avg_on,
        avg_cadence_zero_avg_off,
        max_cadence,
        avg_speed,
        ascent,
        descent,
        max_altitude,
        avg_watts_zero_avg_on,
        avg_watts_zero_avg_off,
        max_watts
    )
end

"""
    loadTCXFile(filepath::String, csv_filepath::Union{String,Nothing}=nothing)

Load a TCX file and parse its contents. If the document contains no
`Activities` element, the returned activity vector is empty. Present malformed
non-trackpoint metadata throws an error; malformed trackpoints are warned about
and skipped.

# Arguments
- `filepath`: The path to the TCX file.
- `csv_filepath`: Optional. If provided, the parsed data will be exported to this CSV file.

# Returns
- A tuple containing the parsed `TCXAuthor` and a vector of `TCXActivity` objects.
"""
function loadTCXFile(filepath::String, csv_filepath::Union{String,Nothing}=nothing)
    doc = readxml(filepath)
    parsed_author = parseTCXAuthor(doc)

    activitiesNode = findfirst(".//g:Activities", doc.root, NS_MAP)
    activities = Vector{TCXActivity}()

    if activitiesNode !== nothing
        for activityNode in findall("./g:Activity", activitiesNode, NS_MAP)
            sport = haskey(activityNode, "Sport") ? activityNode["Sport"] : ""
            idNode = findfirst("./g:Id", activityNode, NS_MAP)
            id = idNode !== nothing ? parseDateTime(nodecontent(idNode)) : DateTime(1, 1, 1)
            lapNodes = findall("./g:Lap", activityNode, NS_MAP)
            parsed_laps = [parseTCXLap(lap) for lap in lapNodes]
            creatorNode = findfirst("./g:Creator", activityNode, NS_MAP)
            device_info = _parseDeviceInfo(creatorNode)

            # Calculate averages and totals for the activity
            total_time, total_distance, max_speed, total_calories, avg_hr, max_hr, avg_cadence_zero_avg_on, avg_cadence_zero_avg_off, max_cadence, avg_speed, ascent, descent, max_altitude, avg_watts_zero_avg_on, avg_watts_zero_avg_off, max_watts = calculate_averages_and_totals(parsed_laps)

            # Create TCXActivity with averages and totals
            activity = TCXActivity(
                sport, id, parsed_laps, device_info, total_time, total_distance, max_speed, total_calories, avg_hr, max_hr,
                avg_cadence_zero_avg_on, avg_cadence_zero_avg_off, max_cadence, avg_speed, ascent, descent, max_altitude,
                avg_watts_zero_avg_on, avg_watts_zero_avg_off, max_watts
            )

            push!(activities, activity)
        end
    end

    if csv_filepath !== nothing
        exportCSV(parsed_author, activities, csv_filepath)
    end

    return parsed_author, activities
end

include("cli.jl")

end

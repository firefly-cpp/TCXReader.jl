module TCXReader

__precompile__(false)

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
    parseDateTime(timeStr::String)

Parse a date-time string into a `DateTime` object. If the string is empty, return a default `DateTime` value.

# Arguments
- `timeStr`: The date-time string to parse.

# Returns
- `DateTime` object.
"""
function parseDateTime(timeStr::String)
    isempty(timeStr) ? DateTime(1, 1, 1) : DateTime(timeStr, dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
end

"""
    parseTCXLap(node::EzXML.Node)::TCXLap

Parse a TCX lap node into a `TCXLap` object.

# Arguments
- `node`: The XML node representing the lap.

# Returns
- `TCXLap` object.
"""
function parseTCXLap(node::EzXML.Node)::TCXLap
    startTime = parseDateTime(node["StartTime"])
    totalTimeSeconds = parseOptionalFloat(node, ".//g:TotalTimeSeconds")
    distanceMeters = parseOptionalFloat(node, ".//g:DistanceMeters")
    maximumSpeed = parseOptionalFloat(node, ".//g:MaximumSpeed")
    calories = parseOptionalInt(node, ".//g:Calories")
    averageHeartRateBpm = parseOptionalInt(node, ".//g:AverageHeartRateBpm/g:Value")
    maximumHeartRateBpm = parseOptionalInt(node, ".//g:MaximumHeartRateBpm/g:Value")
    intensity = parseOptionalString(node, ".//g:Intensity")
    cadence = parseOptionalInt(node, ".//g:Cadence")
    triggerMethod = parseOptionalString(node, ".//g:TriggerMethod")
    avgSpeed = parseOptionalFloat(node, ".//ns3:LX/ns3:AvgSpeed")

    trackPoints = TCXTrackPoint[]
        trackpoint_nodes = findall(".//g:Trackpoint", node, NS_MAP)
        if !isempty(trackpoint_nodes)
            trackPoints = [tp for tp in [parseTCXTrackPoint(tp_node) for tp_node in trackpoint_nodes] if tp !== nothing]
        end

    return TCXLap(startTime, totalTimeSeconds=totalTimeSeconds, distanceMeters=distanceMeters, maximumSpeed=maximumSpeed,
        calories=calories, averageHeartRateBpm=averageHeartRateBpm, maximumHeartRateBpm=maximumHeartRateBpm,
        intensity=intensity, cadence=cadence, trackPoints=trackPoints, triggerMethod=triggerMethod, avgSpeed=avgSpeed)
end

"""
    parseTCXTrackPoint(node::EzXML.Node)

Parse a TCX track point node into a `TCXTrackPoint` object.

# Arguments
- `node`: The XML node representing the track point.

# Returns
- `TCXTrackPoint` object.
"""
function parseTCXTrackPoint(node::EzXML.Node)::Union{TCXTrackPoint, Nothing}
    try
        time = parseDateTime(nodecontent(findfirst(".//g:Time", node, NS_MAP)))

        latitude = parseOptionalFloat(node, ".//g:Position/g:LatitudeDegrees")
        longitude = parseOptionalFloat(node, ".//g:Position/g:LongitudeDegrees")

        altitude_meters = parseOptionalFloat(node, ".//g:AltitudeMeters")
        distance_meters = parseOptionalFloat(node, ".//g:DistanceMeters")

        heart_rate_bpm_node = findfirst(".//g:HeartRateBpm/g:Value", node, NS_MAP)
        heart_rate_bpm = heart_rate_bpm_node !== nothing ? parseOptionalInt(node, ".//g:HeartRateBpm/g:Value") : nothing

        cadence = parseOptionalInt(node, ".//g:Cadence")

        tpx_node = findfirst(".//ns3:TPX", node, NS_MAP)
        speed = nothing
        watts = nothing

        if tpx_node !== nothing
            speed_node = findfirst(".//ns3:Speed", tpx_node, NS_MAP)
            speed = speed_node !== nothing ? parseOptionalFloat(tpx_node, ".//ns3:Speed") : nothing

            watts_node = findfirst(".//ns3:Watts", tpx_node, NS_MAP)
            watts = watts_node !== nothing ? parseOptionalInt(tpx_node, ".//ns3:Watts") : nothing
        else
            @debug "Empty <ns3:TPX> tag found at time $time."
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
    versionMajor = parse(Int, nodecontent(findfirst(".//g:VersionMajor", node, NS_MAP)))
    versionMinor = parse(Int, nodecontent(findfirst(".//g:VersionMinor", node, NS_MAP)))
    buildMajor = parse(Int, nodecontent(findfirst(".//g:BuildMajor", node, NS_MAP)))
    buildMinor = parse(Int, nodecontent(findfirst(".//g:BuildMinor", node, NS_MAP)))

    return BuildVersion(versionMajor, versionMinor, buildMajor, buildMinor)
end

"""
    parseTCXAuthor(doc::EzXML.Document)

Parse the author information from a TCX document into a `TCXAuthor` object.

# Arguments
- `doc`: The XML document representing the TCX file.

# Returns
- `TCXAuthor` object.
"""
function parseTCXAuthor(doc::EzXML.Document)::TCXAuthor
    authorNode = findfirst(".//g:Author", doc.root, NS_MAP)

    if authorNode !== nothing
        name = nodecontent(findfirst(".//g:Name", authorNode, NS_MAP))
        buildNode = findfirst(".//g:Build", authorNode, NS_MAP)
        build = buildNode !== nothing ? parseBuildVersion(buildNode) : BuildVersion(0, 0, 0, 0)
        langID = nodecontent(findfirst(".//g:LangID", authorNode, NS_MAP))
        partNumber = nodecontent(findfirst(".//g:PartNumber", authorNode, NS_MAP))

        return TCXAuthor(name, build, langID, partNumber)
    else
        return TCXAuthor()
    end
end

"""
    parseDeviceInfo(doc::EzXML.Document)

Parse the device information from a TCX document into a `DeviceInfo` object.

# Arguments
- `doc`: The XML document representing the TCX file.

# Returns
- `DeviceInfo` object.
"""
function parseDeviceInfo(doc::EzXML.Document)::DeviceInfo
    creatorNode = findfirst(".//g:Creator", doc.root, NS_MAP)
    if creatorNode !== nothing
        name = nodecontent(findfirst(".//g:Name", creatorNode, NS_MAP))
        unitId = nodecontent(findfirst(".//g:UnitId", creatorNode, NS_MAP))
        productId = parseOptionalInt(creatorNode, ".//g:ProductID")
        versionMajor = parseOptionalInt(creatorNode, ".//g:Version/g:VersionMajor")
        versionMinor = parseOptionalInt(creatorNode, ".//g:Version/g:VersionMinor")
        version = versionMajor !== nothing && versionMinor !== nothing ? "$versionMajor.$versionMinor" : ""
        return DeviceInfo(name, unitId, productId, version)
    else
        return DeviceInfo()
    end
end

"""
    exportCSV(author::TCXAuthor, activities::Vector{TCXActivity}, csv_filepath::String)

Export the parsed TCX data to a CSV file.

# Arguments
- `author`: The `TCXAuthor` object containing author information.
- `activities`: A vector of `TCXActivity` objects representing the activities.
- `csv_filepath`: The file path where the CSV file will be saved.
"""
function exportCSV(author::TCXAuthor, activities::Vector{TCXActivity}, csv_filepath::String)
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

    CSV.write(csv_filepath, df; writeheader=true)
    println("Exported complete TCX data to $csv_filepath")
end

"""
    calculate_averages_and_totals(lap_data::Vector{TCXLap})

Calculate the total values for time, distance, and calories, and average values for other metrics across all laps.

# Arguments
- `lap_data`: A vector of `TCXLap` objects representing the laps.

# Returns
- A tuple containing total values for time, distance, calories, ascent, descent, and average values for maximum speed, average heart rate, maximum heart rate, cadence (Zero Averaging ON and OFF), maximum cadence, average speed, max altitude, average watts (Zero Averaging ON and OFF), and max watts.
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

Load a TCX file and parse its contents.

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

    for activityNode in findall(".//g:Activity", activitiesNode, NS_MAP)
        sport = activityNode["Sport"]
        idNode = findfirst("g:Id", activityNode, NS_MAP)
        id = idNode !== nothing ? parseDateTime(nodecontent(idNode)) : DateTime(1, 1, 1)
        lapNodes = findall(".//g:Lap", activityNode, NS_MAP)
        parsed_laps = [parseTCXLap(lap) for lap in lapNodes]
        device_info = parseDeviceInfo(doc)

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

    if csv_filepath !== nothing
        exportCSV(parsed_author, activities, csv_filepath)
    end

    return parsed_author, activities
end

end
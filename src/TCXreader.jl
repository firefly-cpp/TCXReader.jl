module TCXreader

include("TCXTrackPoint.jl")
include("TCXAuthor.jl")
include("TCXLap.jl")
include("TCXActivity.jl")

using .TrackPoint: TCXTrackPoint
using .Author: TCXAuthor, BuildVersion
using .Lap: TCXLap
using .Activity: TCXActivity, DeviceInfo

using EzXML
using Dates

export loadTCXFile

const NS_MAP = Dict(
    "g" => "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2",
    "ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2"
)

function parseOptionalFloat(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? parse(Float64, nodecontent(valueNode)) : nothing
end

function parseOptionalInt(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? parse(Int, nodecontent(valueNode)) : nothing
end

function parseOptionalString(node, path)
    valueNode = findfirst(path, node, NS_MAP)
    valueNode !== nothing ? nodecontent(valueNode) : ""
end

function parseDateTime(timeStr::String)
    isempty(timeStr) ? DateTime(1, 1, 1) : DateTime(timeStr, dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
end

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

    trackPoints = [parseTCXTrackPoint(tp) for tp in findall(".//g:Trackpoint", node, NS_MAP)]

    return TCXLap(startTime, totalTimeSeconds=totalTimeSeconds, distanceMeters=distanceMeters, maximumSpeed=maximumSpeed,
        calories=calories, averageHeartRateBpm=averageHeartRateBpm, maximumHeartRateBpm=maximumHeartRateBpm,
        intensity=intensity, cadence=cadence, trackPoints=trackPoints, triggerMethod=triggerMethod, avgSpeed=avgSpeed)
end

function parseTCXTrackPoint(node::EzXML.Node)
    time = parseDateTime(nodecontent(findfirst(".//g:Time", node, NS_MAP)))
    latitude = parseOptionalFloat(node, ".//g:Position/g:LatitudeDegrees")
    longitude = parseOptionalFloat(node, ".//g:Position/g:LongitudeDegrees")
    altitude_meters = parseOptionalFloat(node, ".//g:AltitudeMeters")
    distance_meters = parseOptionalFloat(node, ".//g:DistanceMeters")
    heart_rate_bpm = parseOptionalInt(node, ".//g:HeartRateBpm/g:Value")
    speed = parseOptionalFloat(node, ".//ns3:TPX/ns3:Speed")

    return TCXTrackPoint(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)
end

function parseBuildVersion(node::EzXML.Node)
    versionMajor = parse(Int, nodecontent(findfirst(".//g:VersionMajor", node, NS_MAP)))
    versionMinor = parse(Int, nodecontent(findfirst(".//g:VersionMinor", node, NS_MAP)))
    buildMajor = parse(Int, nodecontent(findfirst(".//g:BuildMajor", node, NS_MAP)))
    buildMinor = parse(Int, nodecontent(findfirst(".//g:BuildMinor", node, NS_MAP)))

    return BuildVersion(versionMajor, versionMinor, buildMajor, buildMinor)
end

function parseTCXAuthor(doc::EzXML.Document)
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

function parseDeviceInfo(doc::EzXML.Document)
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

function loadTCXFile(filepath::String)
    doc = readxml(filepath)
    parsed_author = parseTCXAuthor(doc)

    activitiesNode = findfirst(".//g:Activities", doc.root, NS_MAP)
    activities = []

    for activityNode in findall(".//g:Activity", activitiesNode, NS_MAP)
        sport = activityNode["Sport"]
        idNode = findfirst("g:Id", activityNode, NS_MAP)
        id = idNode !== nothing ? parseDateTime(nodecontent(idNode)) : DateTime(1, 1, 1)
        lapNodes = findall(".//g:Lap", activityNode, NS_MAP)
        parsed_laps = [parseTCXLap(lap) for lap in lapNodes]
        device_info = parseDeviceInfo(doc)

        push!(activities, TCXActivity(sport, id, parsed_laps, device_info))
    end

    return parsed_author, activities
end

end
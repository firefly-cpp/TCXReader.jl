module TCXreader

include("TCXTrackPoint.jl")
include("TCXAuthor.jl")

using .TrackPoint: TCXTrackPoint
using .Author: TCXAuthor, BuildVersion

using EzXML
using Dates

export loadTCXFile

const NS_MAP = Dict(
    "g" => "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2",
    "ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2"
)

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
        return TCXAuthor()  # Return an empty author if not found
    end
end

function parseDateTime(timeStr::String)
    isempty(timeStr) ? DateTime(1, 1, 1) : DateTime(timeStr, dateformat"yyyy-mm-ddTHH:MM:SS.sssZ")
end

function parseValue(node::Union{Nothing,EzXML.Node}, parser::Function=identity)
    node === nothing ? nothing : parser(nodecontent(node))
end

function parseTCXTrackPoint(node::EzXML.Node)    
    time = parseDateTime(nodecontent(findfirst(".//g:Time", node, NS_MAP)))
    latitude = parseValue(findfirst(".//g:Position/g:LatitudeDegrees", node, NS_MAP), x -> parse(Float64, x))
    longitude = parseValue(findfirst(".//g:Position/g:LongitudeDegrees", node, NS_MAP), x -> parse(Float64, x))
    altitude_meters = parseValue(findfirst(".//g:AltitudeMeters", node, NS_MAP), x -> parse(Float64, x))
    distance_meters = parseValue(findfirst(".//g:DistanceMeters", node, NS_MAP), x -> parse(Float64, x))
    heart_rate_bpm = parseValue(findfirst(".//g:HeartRateBpm/g:Value", node, NS_MAP), x -> parse(Int, x))
    speed = parseValue(findfirst(".//ns3:TPX/ns3:Speed", node, NS_MAP), x -> parse(Float64, x))

    return TCXTrackPoint(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)
end

function loadTCXFile(filepath::String)
    doc = readxml(filepath)

    parsed_author = parseTCXAuthor(doc)
    parsed_trackpoints = [parseTCXTrackPoint(tp) for tp in findall(".//g:Trackpoint", doc.root, NS_MAP)]

    return parsed_author, parsed_trackpoints
end

end

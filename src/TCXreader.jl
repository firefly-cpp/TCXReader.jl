module TCXreader

using EzXML
using Dates

include("TCXTrackPoint.jl")
using .TrackPoint: TCXTrackPoint

export loadTCXFile

const NS_MAP = Dict(
    "g" => "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2",
    "ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2"
)

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
    trackpoints = findall(".//g:Trackpoint", doc.root, NS_MAP)

    println("Found ", length(trackpoints), " trackpoints.")

    parsed_trackpoints = [parseTCXTrackPoint(tp) for tp in trackpoints]

    return parsed_trackpoints
end

end

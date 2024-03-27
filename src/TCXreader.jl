module TCXreader

using EzXML
using Dates
include("TCXTrackPoint.jl")
using .TrackPoint: TCXTrackPoint

export loadTCXFile

const GARMIN_XML_SCHEMA = "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
const GARMIN_XML_EXTENSIONS = "http://www.garmin.com/xmlschemas/ActivityExtension/v2"

function parseTCXTrackPoint(node::EzXML.Node)

    # Extract Time
    timeStr = nodecontent.(findall(".//g:Time", node, ["g" => namespace(node)]))[1]
    time = timeStr != "" ? DateTime(timeStr, dateformat"yyyy-mm-ddTHH:MM:SS.sssZ") : DateTime(1, 1, 1)

    # Extract Latitude and Longitude
    latitudeNode = findfirst(".//g:Position/g:LatitudeDegrees", node, ["g" => namespace(node)])
    longitudeNode = findfirst(".//g:Position/g:LongitudeDegrees", node, ["g" => namespace(node)])
    latitude = latitudeNode !== nothing ? parse(Float64, nodecontent(latitudeNode)) : nothing
    longitude = longitudeNode !== nothing ? parse(Float64, nodecontent(longitudeNode)) : nothing

    # Extract AltitudeMeters
    altitudeMetersNode = findfirst(".//g:AltitudeMeters", node, ["g" => namespace(node)])
    altitude_meters = altitudeMetersNode !== nothing ? parse(Float64, nodecontent(altitudeMetersNode)) : nothing

    # Extract DistanceMeters
    distanceMetersNode = findfirst(".//g:DistanceMeters", node, ["g" => namespace(node)])
    distance_meters = distanceMetersNode !== nothing ? parse(Float64, nodecontent(distanceMetersNode)) : nothing

    # Extract HeartRateBpm
    heartRateBpmNode = findfirst(".//g:HeartRateBpm/g:Value", node, ["g" => namespace(node)])
    heart_rate_bpm = heartRateBpmNode !== nothing ? parse(Int, nodecontent(heartRateBpmNode)) : nothing

    # Extract Speed
    speedNode = findfirst(".//ns3:TPX/ns3:Speed", node, ["ns3" => "http://www.garmin.com/xmlschemas/ActivityExtension/v2"])  
    speed = speedNode !== nothing ? parse(Float64, nodecontent(speedNode)) : nothing

    return TCXTrackPoint(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)

end

function loadTCXFile(filepath::String)
    doc = readxml(filepath)

    trackpoints = findall(".//g:Trackpoint", doc.root, ["g" => GARMIN_XML_SCHEMA])

    println("Found ", length(trackpoints), " trackpoints.")

    parsed_trackpoints = []

    for tp in trackpoints
        push!(parsed_trackpoints, parseTCXTrackPoint(tp))
    end

    return parsed_trackpoints
end

end

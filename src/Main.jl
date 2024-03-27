include("TCXTrackPoint.jl")
include("TCXreader.jl")

using .TCXreader

function main()
    track_points = loadTCXFile("../example_data/15.tcx")
    for tp in track_points
        println("Time: ", tp.time, ", Latitude: ", tp.latitude, ", Longitude: ", tp.longitude, ", Altitude: ", tp.altitude_meters, ", Distance: ", tp.distance_meters, ", Heart Rate: ", tp.heart_rate_bpm, ", Speed: ", tp.speed)
    end
end

main()

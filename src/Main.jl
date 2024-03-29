include("TCXreader.jl")

using .TCXreader

function main()
    author, track_points = loadTCXFile("../example_data/15.tcx")
    
    # Displaying author information
    println("Author Information:")
    println("Name: ", author.name)
    println("Build Version: ", author.build.versionMajor, ".", author.build.versionMinor)
    println("Build Major: ", author.build.buildMajor, ", Build Minor: ", author.build.buildMinor)
    println("Language ID: ", author.langID)
    println("Part Number: ", author.partNumber)
    println("===================================")

    # Displaying track points
    println("Track Points:")
    for tp in track_points
        println("Time: ", tp.time, ", Latitude: ", tp.latitude, ", Longitude: ", tp.longitude, 
                ", Altitude: ", tp.altitude_meters, ", Distance: ", tp.distance_meters, 
                ", Heart Rate: ", tp.heart_rate_bpm, ", Speed: ", tp.speed)
    end
end

main()

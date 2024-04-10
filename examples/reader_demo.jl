include("../src/TCXReader.jl")

using .TCXReader: loadTCXFile

function main()
    author, activities = loadTCXFile("../example_data/15.tcx")

    # Displaying author information
    println("Author Information:")
    println("Name: ", author.name)
    println("Build Version: ", author.build.versionMajor, ".", author.build.versionMinor)
    println("Build Major: ", author.build.buildMajor, ", Build Minor: ", author.build.buildMinor)
    println("Language ID: ", author.langID)
    println("Part Number: ", author.partNumber)
    println("===================================")

    for activity in activities
        # Displaying activity information
        println("Activity Information:")
        println("Sport: ", activity.sport)
        println("ID: ", activity.id)
        println("Device Name: ", activity.device.name)
        println("Device Version: ", activity.device.version)
        println("===================================")

        # Displaying laps and their track points for each activity
        println("Laps and Track Points:")
        for (i, lap) in enumerate(activity.laps)
            println("\nLap #$i:")
            println("\tStart Time: ", lap.startTime)
            println("\tTotal Time Seconds: ", lap.totalTimeSeconds)
            println("\tDistance Meters: ", lap.distanceMeters)
            println("\tMaximum Speed: ", lap.maximumSpeed)
            println("\tCalories: ", lap.calories)
            println("\tAverage Heart Rate Bpm: ", lap.averageHeartRateBpm)
            println("\tMaximum Heart Rate Bpm: ", lap.maximumHeartRateBpm)
            println("\tIntensity: ", lap.intensity)
            println("\tCadence: ", lap.cadence)
            println("\tTrigger Method: ", lap.triggerMethod)
            println("\tAverage Speed: ", lap.avgSpeed)
            println("\tTrack Points:")
            for tp in lap.trackPoints
                println("\t\tTime: ", tp.time, ", Latitude: ", tp.latitude, ", Longitude: ", tp.longitude,
                    ", Altitude: ", tp.altitude_meters, ", Distance: ", tp.distance_meters,
                    ", Heart Rate: ", tp.heart_rate_bpm, ", Speed: ", tp.speed)
            end
        end
        println("===================================")
    end

    # Load a TCX file and export the data to CSV
    author, activities = loadTCXFile("../example_data/15.tcx", "tcx_data_export.csv")

end

main()

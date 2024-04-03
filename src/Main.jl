include("TCXreader.jl")

using TCXreader
using CSV, DataFrames

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

    # Initialize a DataFrame to store our data
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
        AverageHR = Int[],
        MaximumHR = Int[],
        Intensity = String[]
    )

    # Loop through activities and their laps to populate the DataFrame
    for activity in activities
        for (i, lap) in enumerate(activity.laps)
            push!(df, (
                author.name,
                string(author.build.versionMajor, ".", author.build.versionMinor),
                author.langID,
                author.partNumber,
                activity.sport,
                string(activity.id),
                activity.device.name,
                activity.device.version,
                i,
                string(lap.startTime),
                lap.totalTimeSeconds,
                lap.distanceMeters,
                lap.calories,
                isnothing(lap.averageHeartRateBpm) ? missing : lap.averageHeartRateBpm,
                isnothing(lap.maximumHeartRateBpm) ? missing : lap.maximumHeartRateBpm,
                lap.intensity
            ))
        end
    end

    # Write the DataFrame to a CSV file
    CSV.write("tcx_data_export.csv", df)

    println("Exported TCX data to tcx_data_export.csv")
end

main()

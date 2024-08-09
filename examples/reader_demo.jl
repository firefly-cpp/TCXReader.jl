include("../src/TCXReader.jl")

using .TCXReader: loadTCXFile

function main()
    author, activities = loadTCXFile("../example_data/23.tcx")

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
        println("Total Time (seconds): ", activity.total_time)
        println("Total Distance (meters): ", activity.total_distance)
        println("Maximum Speed: ", activity.max_speed)
        println("Total Calories: ", activity.total_calories)
        println("Average Heart Rate (BPM): ", activity.avg_hr)
        println("Maximum Heart Rate (BPM): ", activity.max_hr)
        println("Average Cadence (Zero Averaging ON): ", activity.avg_cadence_zero_avg_on)
        println("Average Cadence (Zero Averaging OFF): ", activity.avg_cadence_zero_avg_off)
        println("Maximum Cadence: ", activity.max_cadence)
        println("Average Speed: ", activity.avg_speed)
        println("Total Ascent (meters): ", activity.total_ascent)
        println("Total Descent (meters): ", activity.total_descent)
        println("Maximum Altitude (meters): ", activity.max_altitude)
        println("Average Watts (Zero Averaging ON): ", activity.avg_watts_zero_avg_on)
        println("Average Watts (Zero Averaging OFF): ", activity.avg_watts_zero_avg_off)
        println("Maximum Watts: ", activity.max_watts)
        println("===================================")
    end

    # Load a TCX file and export the data to CSV
    author, activities = loadTCXFile("../example_data/23.tcx", "tcx_data_export.csv")
end

main()

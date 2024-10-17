include("../src/TCXReader.jl")

using .TCXReader: loadTCXFile
using Glob

function main()
    # Get all TCX files from folder
    folder_path = "../example_data/test/"
    tcx_files = Glob.glob("*.tcx", folder_path)  # This gets all .tcx files in the folder

    for tcx_file in tcx_files
        println("Reading file: ", tcx_file)

        try
            # Load the TCX file
            author, activities = loadTCXFile(tcx_file)

            # Display author information
            println("Author Information:")
            println("Name: ", author.name)
            println("Build Version: ", author.build.versionMajor, ".", author.build.versionMinor)
            println("Build Major: ", author.build.buildMajor, ", Build Minor: ", author.build.buildMinor)
            println("Language ID: ", author.langID)
            println("Part Number: ", author.partNumber)
            println("===================================")

            for activity in activities
                # Display activity information
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

            # Optional: Export to CSV if needed
            # loadTCXFile(tcx_file, "tcx_data_export.csv")

        catch e
            # Handle errors: stop the loop and print the file that caused the issue
            println("Error reading file: ", tcx_file)
            println("Error: ", e)
            break  # Stop the loop if an error occurs
        end
    end
end

main()

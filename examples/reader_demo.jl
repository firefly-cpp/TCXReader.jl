using TCXReader: loadTCXFile

function main()
    data_dir = normpath(joinpath(@__DIR__, "..", "example_data"))
    tcx_files = sort!(filter(
        path -> isfile(path) && endswith(lowercase(path), ".tcx"),
        readdir(data_dir; join=true),
    ))

    for tcx_file in tcx_files
        println("Reading file: ", basename(tcx_file))
        author, activities = loadTCXFile(tcx_file)

        println("  Author: ", isempty(author.name) ? "unknown" : author.name)
        println("  Activities: ", length(activities))

        for (index, activity) in enumerate(activities)
            println("  Activity $index:")
            println("    Sport: ", activity.sport)
            println("    ID: ", activity.id)
            println("    Device: ", isempty(activity.device.name) ? "unknown" : activity.device.name)
            println("    Laps: ", length(activity.laps))
            println("    Time: ", activity.total_time, " s")
            println("    Distance: ", activity.total_distance, " m")
            println("    Average heart rate: ", activity.avg_hr, " bpm")
            println("    Average speed: ", activity.avg_speed, " m/s")
        end

        println()
    end
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && main()

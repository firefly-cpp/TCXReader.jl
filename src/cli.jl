const _CLI_USAGE = """Usage:
  tcxreader [--csv OUTPUT.csv] [--] INPUT.tcx
  tcxreader --help
  tcxreader --version

Options:
  --csv OUTPUT.csv  Export trackpoints to a CSV file.
  -h, --help        Show this help message.
  --version         Show the TCXReader version.
"""

_cli_version() = string(pkgversion(@__MODULE__))

function _print_cli_help(io::IO)
    println(io, "TCXReader ", _cli_version())
    println(io)
    print(io, _CLI_USAGE)
end

function _cli_error(message::String)
    return (mode=:error, input=nothing, csv=nothing, message=message)
end

function _parse_cli_arguments(args)
    input_path = nothing
    csv_path = nothing
    parse_options = true
    index = 1

    while index <= length(args)
        argument = String(args[index])

        if parse_options && argument == "--"
            parse_options = false
        elseif parse_options && (argument == "--help" || argument == "-h")
            return (mode=:help, input=nothing, csv=nothing, message=nothing)
        elseif parse_options && argument == "--version"
            return (mode=:version, input=nothing, csv=nothing, message=nothing)
        elseif parse_options && argument == "--csv"
            csv_path !== nothing && return _cli_error("--csv may only be specified once")
            index == length(args) && return _cli_error("--csv requires an output path")
            index += 1
            csv_path = String(args[index])
        elseif parse_options && startswith(argument, "-")
            return _cli_error("unknown option: $argument")
        elseif input_path === nothing
            input_path = argument
        else
            return _cli_error("expected one input TCX file, received an extra argument: $argument")
        end

        index += 1
    end

    input_path === nothing && return _cli_error("an input TCX file is required")
    return (mode=:run, input=input_path, csv=csv_path, message=nothing)
end

_format_cli_number(value::Real) = string(round(value; digits=2))

function _device_label(device::DeviceInfo)
    name = isempty(device.name) ? "unknown" : device.name
    return isempty(device.version) ? name : "$name (version $(device.version))"
end

function _print_cli_summary(io::IO, input_path::String, author::TCXAuthor, activities::Vector{TCXActivity})
    println(io, "TCX file: ", input_path)
    println(io, "Author: ", isempty(author.name) ? "unknown" : author.name)
    println(io, "Activities: ", length(activities))

    for (index, activity) in enumerate(activities)
        println(io)
        println(io, "Activity ", index)
        println(io, "  Sport: ", isempty(activity.sport) ? "unknown" : activity.sport)
        if activity.id == DateTime(1, 1, 1)
            println(io, "  ID: unknown")
        else
            println(io, "  ID: ", activity.id, " UTC")
        end
        println(io, "  Device: ", _device_label(activity.device))
        println(io, "  Laps: ", length(activity.laps))
        println(io, "  Duration: ", _format_cli_number(activity.total_time), " s")
        println(io, "  Distance: ", _format_cli_number(activity.total_distance), " m")
        println(io, "  Calories: ", _format_cli_number(activity.total_calories), " kcal")
        println(
            io,
            "  Heart rate: avg ",
            _format_cli_number(activity.avg_hr),
            " bpm, max ",
            _format_cli_number(activity.max_hr),
            " bpm",
        )
        println(
            io,
            "  Speed: avg ",
            _format_cli_number(activity.avg_speed),
            " m/s, max ",
            _format_cli_number(activity.max_speed),
            " m/s",
        )
        println(
            io,
            "  Elevation: ascent ",
            _format_cli_number(activity.total_ascent),
            " m, descent ",
            _format_cli_number(activity.total_descent),
            " m, max ",
            _format_cli_number(activity.max_altitude),
            " m",
        )
        println(
            io,
            "  Power: avg ",
            _format_cli_number(activity.avg_watts_zero_avg_on),
            " W (zeros excluded), avg ",
            _format_cli_number(activity.avg_watts_zero_avg_off),
            " W (zeros included), max ",
            _format_cli_number(activity.max_watts),
            " W",
        )
    end
end

"""
    _cli_main(args, stdout, stderr) -> Int

Run the dependency-free TCXReader command-line interface. The return value is
`0` on success, `1` when reading, parsing, or exporting fails, and `2` for
invalid command-line usage.
"""
function _cli_main(args, out::IO=stdout, err::IO=stderr)::Int
    if isempty(args)
        _print_cli_help(out)
        return 0
    end

    parsed = _parse_cli_arguments(args)
    if parsed.mode === :help
        _print_cli_help(out)
        return 0
    elseif parsed.mode === :version
        println(out, "TCXReader ", _cli_version())
        return 0
    elseif parsed.mode === :error
        println(err, "Error: ", parsed.message)
        println(err)
        print(err, _CLI_USAGE)
        return 2
    end

    try
        author, activities = loadTCXFile(parsed.input)
        if parsed.csv !== nothing
            exportCSV(author, activities, parsed.csv; io=out)
        end
        _print_cli_summary(out, parsed.input, author, activities)
        return 0
    catch error
        println(err, "Error: ", sprint(showerror, error))
        return 1
    end
end

# Using TCXReader

## Julia API

[`loadTCXFile`](@ref) is the main entry point. It returns a [`TCXAuthor`](@ref) and a vector of [`TCXActivity`](@ref) values:

```julia
using TCXReader: loadTCXFile

author, activities = loadTCXFile("activity.tcx")

for activity in activities
    println("Sport: ", activity.sport)
    println("Started: ", activity.id)
    println("Device: ", activity.device.name)
    println("Laps: ", length(activity.laps))
    println("Distance: ", activity.total_distance, " m")
    println("Duration: ", activity.total_time, " s")
end
```

TCX timestamps are returned as timezone-free `Dates.DateTime` values representing UTC. The parser accepts `Z`, numeric UTC offsets, or no offset (treated as UTC), with optional fractional seconds. Precision finer than milliseconds is truncated to match `DateTime`. Missing activity IDs and lap start times use `DateTime(1, 1, 1)`; a track point without a valid timestamp is warned about and skipped.

Optional track-point measurements are `nothing` when absent. Missing lap, author, build, and device metadata use their documented constructor defaults. A document without an `Activities` element returns an empty activity vector. Malformed individual track points produce a warning and are skipped; malformed numeric metadata elsewhere remains an error.

## CSV export

Supply an output path while loading:

```julia
author, activities = loadTCXFile("activity.tcx", "trackpoints.csv")
```

Or export data that has already been loaded:

```julia
using TCXReader: exportCSV

exportCSV(author, activities, "trackpoints.csv")
```

The CSV contains one row per track point. Author, activity, and lap metadata are repeated for each corresponding point. Missing optional values are written as empty cells, and a lap with no track points contributes no rows.

The column order is stable:

```text
AuthorName, AuthorBuildVersion, AuthorLangID, AuthorPartNumber,
ActivitySport, ActivityID, DeviceName, DeviceVersion, LapNumber,
StartTime, TotalTimeSeconds, DistanceMeters, Calories, AverageHR,
MaximumHR, Intensity, TrackPointTime, Latitude, Longitude,
AltitudeMeters, DistanceMetersTP, HeartRateBpm, Cadence, Speed, Watts
```

## Command-line interface

From a source checkout, run:

```shell
julia --project=. bin/tcxreader.jl [--csv OUTPUT.csv] [--] INPUT.tcx
```

Examples:

```shell
julia --project=. bin/tcxreader.jl activity.tcx
julia --project=. bin/tcxreader.jl --csv trackpoints.csv activity.tcx
julia --project=. bin/tcxreader.jl --version
julia --project=. bin/tcxreader.jl --help
```

The summary reports the author and activity count, then each activity's sport, ID, recording device, lap count, duration, distance, calories, heart rate, speed, elevation, and power with units. Use `--` before an input path that begins with `-`.

The process exits with status `0` after success, `1` for file, XML, parsing, or CSV-export failures, and `2` for invalid command-line usage.

## Docker

Release images use the CLI as their entrypoint and run as an unprivileged user. Replace `<dockerhub-username>` with the namespace listed on the release page:

```shell
docker pull <dockerhub-username>/tcxreader:0.3.0

docker run --rm \
    -v "$PWD:/data:ro" \
    <dockerhub-username>/tcxreader:0.3.0 \
    /data/activity.tcx
```

Mount the destination as writable when exporting CSV:

```shell
docker run --rm \
    -v "$PWD:/data" \
    <dockerhub-username>/tcxreader:0.3.0 \
    --csv /data/trackpoints.csv /data/activity.tcx
```

Running the image without arguments displays help. Override the entrypoint for an interactive Julia session:

```shell
docker run --rm -it \
    --entrypoint julia \
    <dockerhub-username>/tcxreader:0.3.0
```

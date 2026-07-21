# TCXReader.jl

TCXReader.jl parses Training Center XML (`.tcx`) workout files into Julia objects. It supports author and device metadata, activities, laps, track points, aggregate workout metrics, and trackpoint-level CSV export.

The package requires Julia 1.10 or later.

## Installation

```julia
using Pkg
Pkg.add("TCXReader")
```

At the package prompt, the equivalent command is `add TCXReader`.

## Quick start

```julia
using TCXReader: loadTCXFile

author, activities = loadTCXFile("activity.tcx")
println("Created by: ", author.name)

for activity in activities
    println(activity.sport, ": ", activity.total_distance, " m")
end
```

Pass a second path to write trackpoint-level CSV as part of the same operation:

```julia
author, activities = loadTCXFile("activity.tcx", "trackpoints.csv")
```

The summary calculations can also be used with objects constructed in Julia:

```jldoctest quickstart
julia> using Dates, TCXReader

julia> point = TCXTrackPoint(
           DateTime(2026, 7, 21), 46.0, 14.0, 100.0, 250.0,
           150, 90, 3.0, 200,
       );

julia> lap = TCXLap(
           DateTime(2026, 7, 21);
           totalTimeSeconds=60.0,
           distanceMeters=250.0,
           calories=10,
           trackPoints=[point],
       );

julia> calculate_averages_and_totals([lap])[1:4]
(60.0, 250.0, 3.0, 10.0)
```

## Where to go next

- [Using TCXReader](@ref) covers the Julia API, CLI, Docker image, and CSV format.
- [Calculation semantics](@ref) explains exactly how activity totals and averages are produced.
- [Functions](@ref) and [Types](@ref) provide the API reference.
- The [repository](https://github.com/firefly-cpp/TCXReader.jl) contains sample TCX files and a runnable example.

## Contributing

Issues and pull requests are welcome in the [GitHub repository](https://github.com/firefly-cpp/TCXReader.jl).

TCXReader.jl is distributed under the [MIT License](https://github.com/firefly-cpp/TCXReader.jl/blob/main/LICENSE).

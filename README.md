<p align="center">
    <img width="200" src=".github/logo/tcxreader_jl.webp">
</p>

<h1 align="center">
TCXReader.jl -- A parser for TCX files
</h1>

<p align="center">
    <a href="https://juliahub.com/ui/Packages/General/TCXReader">
        <img alt="Version" src="https://juliahub.com/docs/General/TCXReader/stable/version.svg">
    </a>
    <a href="https://github.com/firefly-cpp/TCXReader.jl/blob/main/LICENSE">
        <img alt="GitHub License" src="https://img.shields.io/github/license/firefly-cpp/TCXReader.jl.svg">
    </a>
    <img alt="GitHub Commit Activity" src="https://img.shields.io/github/commit-activity/w/firefly-cpp/TCXReader.jl.svg">
</p>

<p align="center">
    <a href="#-detailed-insights">✨ Detailed insights</a> •
    <a href="#-installation">📦 Installation</a> •
    <a href="#-usage">🚀 Usage</a> •
    <a href="#-command-line-and-docker">🐳 Command line and Docker</a> •
    <a href="#-documentation">📖 Documentation</a> •
    <a href="#️-datasets">🗃️ Datasets</a> •
    <a href="#-related-packagesframeworks">🔗 Related packages/frameworks</a> •
    <a href="#-license">🔑 License</a>
</p>

TCXReader.jl reads Training Center XML (`.tcx`) workout files produced by Garmin and other fitness devices. It exposes author, device, activity, lap, and track-point data as Julia structs, calculates common activity summaries, and can export track points to CSV. The package API, command-line interface, and container use the same parser.

## ✨ Detailed insights

- **TCXAuthor** stores information about the application that created the file, including its name, build version, language, and part number.
- **TCXActivity** provides the sport, activity timestamp, recording device, laps, and calculated time, distance, heart-rate, cadence, speed, elevation, and power summaries.
- **TCXLap** stores lap metadata and its ordered track points.
- **TCXTrackPoint** stores timestamped position, altitude, distance, heart rate, cadence, speed, and power samples. Values absent from the TCX file are represented by `nothing`.
- Sparse metadata and documents without activities are supported. A malformed individual track point is warned about and skipped so the remaining workout can still be read.

## 📦 Installation

TCXReader.jl requires Julia 1.10 or later. From the Julia package prompt, run:

```julia
pkg> add TCXReader
```

## 🚀 Usage

```julia
using TCXReader: loadTCXFile

author, activities = loadTCXFile("activity.tcx")

println("Created by: ", author.name)
for activity in activities
    println(activity.sport, ": ", activity.total_distance, " m in ",
            activity.total_time, " s")
end
```

Pass a second path to write CSV while loading:

```julia
author, activities = loadTCXFile("activity.tcx", "trackpoints.csv")
```

The CSV contains one row per track point and repeats the corresponding author, activity, and lap metadata on each row. Missing optional track-point values become empty cells; laps without track points do not create rows. The column names and order are documented in the [usage guide](https://firefly-cpp.github.io/TCXReader.jl/stable/usage/).

The repository also includes a runnable example for its bundled sample files:

```shell
julia --project=. examples/reader_demo.jl
```

## 🐳 Command line and Docker

Run the dependency-free CLI from a checkout:

```shell
julia --project=. bin/tcxreader.jl activity.tcx
julia --project=. bin/tcxreader.jl --csv trackpoints.csv activity.tcx
julia --project=. bin/tcxreader.jl --help
```

Released images use the CLI as their entrypoint.

```shell
docker run --rm -v "$PWD:/data:ro" tilenhlis/tcxreader /data/activity.tcx
docker run --rm -v "$PWD:/data" tilenhlis/tcxreader \
    --csv /data/trackpoints.csv /data/activity.tcx
```

To open Julia instead of the CLI, override the entrypoint:

```shell
docker run --rm -it --entrypoint julia tilenhlis/tcxreader
```

## 📖 Documentation

The full manual covers [installation and usage](https://firefly-cpp.github.io/TCXReader.jl/stable/usage/), [calculation semantics](https://firefly-cpp.github.io/TCXReader.jl/stable/calculations/), and the [API reference](https://firefly-cpp.github.io/TCXReader.jl/stable/functions/). Release notes are recorded in the [changelog](CHANGELOG.md).

## 🗃️ Datasets

Datasets available and used in the examples on the following links: [DATASET1](http://iztok-jr-fister.eu/static/publications/Sport5.zip), [DATASET2](http://iztok-jr-fister.eu/static/css/datasets/Sport.zip), [DATASET3](https://github.com/firefly-cpp/tcx-test-files).

## 🔗 Related packages/frameworks

[1] [tcxreader: Python reader/parser for Garmin's TCX file format.](https://github.com/alenrajsp/tcxreader)

[2] [sport-activities-features: A minimalistic toolbox for extracting features from sports activity files written in Python](https://github.com/firefly-cpp/sport-activities-features)

[3] [tcxread: A parser for TCX files written in Ruby](https://github.com/firefly-cpp/tcxread)

[4] [TCX2Graph.jl: Building Property Graphs from TCX Files](https://github.com/firefly-cpp/TCX2Graph.jl)

## 🔑 License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

## Disclaimer

This framework is provided as-is, and there are no guarantees that it fits your purposes or that it is bug-free. Use it at your own risk!

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
    <a href="https://github.com/firefly-cpp/TCXReader.jl/blob/master/LICENSE">
        <img alt="GitHub License" src="https://img.shields.io/github/license/firefly-cpp/TCXReader.jl.svg">
    </a>
    <img alt="GitHub Commit Activity" src="https://img.shields.io/github/commit-activity/w/firefly-cpp/TCXReader.jl.svg">
</p>

<p align="center">
    <a href="#-detailed-insights">✨ Detailed insights</a> •
    <a href="#-installation">📦 Installation</a> •
    <a href="#-usage">🚀 Usage</a> •
    <a href="#️-datasets">🗃️ Datasets</a> •
    <a href="#-related-packagesframeworks">🔗 Related packages/frameworks</a> •
    <a href="#-license">🔑 License</a>
</p>

TCXReader.jl is a Julia package designed to simplify the process of reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data. This package allows Julia developers and data scientists to easily import, analyze, and transform training data for further analysis and visualization. With support for key TCX data elements such as track points, laps, activities, and device information, TCXReader.jl provides a comprehensive toolset for accessing the rich data captured during workouts.

## ✨ Detailed insights
- **TCXReader** is a Julia package that provides a simple interface for reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data.
- **TCXActivity**: Access metadata about the workout, including the activity type, start time, total distance, max speed, average/max heart rate, average/max cadence, average/max watts, total ascent, total descent, and max altitude.
- **TCXAuthor**: Retrieve information about the author of the workout, including name, build version, language ID, and part number.
- **TCXLap**: Retrieve information about laps within a workout, including start and end times, total distance, total time, and maximum speed.
- **TCXTrackPoint**: Access detailed information about each trackpoint in a workout, including time, latitude, longitude, altitude, heart rate, cadence, speed, and watts.

## 📦 Installation

```
pkg> add TCXReader
```

## 🚀 Usage

```julia
using TCXReader: loadTCXFile

# Load a TCX file and access its data
author, activities = loadTCXFile("path/to/your/file.tcx")
```

### Basic run example

```julia
using TCXReader: loadTCXFile

function main()
    # Load a TCX file and access its data
    author, activities = loadTCXFile("path/to/your/file.tcx")

    # Display basic information about the workout's author
    println("Author Information:")
    println("Name: ", author.name)
    println("Build Version: ", author.build.versionMajor, ".", author.build.versionMinor)
    println("Language ID: ", author.langID)
    println("Part Number: ", author.partNumber)

    # Iterate through each activity in the TCX file
    for activity in activities
        println("\nActivity Information:")
        println("Sport: ", activity.sport)
        println("ID: ", activity.id)
        println("Device Name: ", activity.device.name)
        println("Device Version: ", activity.device.version)

        # Display overall metrics for the activity
        println("Total Time (seconds): ", activity.total_time)
        println("Total Distance (meters): ", activity.total_distance)
        println("Maximum Speed: ", activity.max_speed)
        println("Total Calories: ", activity.total_calories)
        println("Average Heart Rate (BPM): ", activity.avg_hr)
        println("Maximum Heart Rate (BPM): ", activity.max_hr)
        println("Average Cadence (Zero Averaging ON): ", activity.avg_cadence_zero_avg_on)
        println("Average Cadence (Zero Averaging OFF): ", activity.avg_cadence_zero_avg_off)
        println("Max Cadence: ", activity.max_cadence)
        println("Average Speed: ", activity.avg_speed)
        println("Total Ascent (meters): ", activity.total_ascent)
        println("Total Descent (meters): ", activity.total_descent)
        println("Max Altitude (meters): ", activity.max_altitude)
        println("Average Watts (Zero Averaging ON): ", activity.avg_watts_zero_avg_on)
        println("Average Watts (Zero Averaging OFF): ", activity.avg_watts_zero_avg_off)
        println("Max Watts: ", activity.max_watts)

        # Display information about each lap within the activity
        println("\nLaps and Track Points:")
        for (i, lap) in enumerate(activity.laps)
            println("Lap #$i:")
            println("\tStart Time: ", lap.startTime)
            println("\tTotal Time Seconds: ", lap.totalTimeSeconds)
            println("\tDistance Meters: ", lap.distanceMeters)
            # Additional lap details here
        end
    end

    # Optionally, export the loaded data to a CSV file for further analysis
    loadTCXFile("path/to/your/file.tcx", "output_path/tcx_data_export.csv")
end

main()

```

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

<div width="200" style="background-color: white; width: 200px">
 <img width="200" style="margin-bottom:-8px" src="https://raw.githubusercontent.com/firefly-cpp/TCXreader.jl/main/.github/logo/tcxreader_jl.webp">
</div>

# TCXReader.jl -- A parser for TCX files

## About 📋

TCXReader.jl is a Julia package designed to simplify the process of reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data. This package allows Julia developers and data scientists to easily import, analyze, and transform training data for further analysis and visualization. With support for key TCX data elements such as track points, laps, activities, and device information, TCXReader.jl provides a comprehensive toolset for accessing the rich data captured during workouts.

## Detailed insights ✨
🚀
- **TCXReader** is a Julia package that provides a simple interface for reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data.
- **TCXActivity**: Access metadata about the workout, including the activity type, start time, and total distance.
- **TCXAuthor**: Retrieve information about the author of the workout, including name, build version, language ID, and part number.
- **TCXLap**: Retrieve information about laps within a workout, including start and end times, total distance, and total time.
- **TCXTrackPoint**: Access detailed information about each trackpoint in a workout, including time, latitude, longitude, altitude, and heart rate.

## Installation 📦

```
pkg> add TCXReader
```

## Usage 🚀

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

## Datasets

Datasets available and used in the examples on the following links: [DATASET1](http://iztok-jr-fister.eu/static/publications/Sport5.zip), [DATASET2](http://iztok-jr-fister.eu/static/css/datasets/Sport.zip), [DATASET3](https://github.com/firefly-cpp/tcx-test-files).

## Related packages/frameworks

[1] [tcxreader: Python reader/parser for Garmin's TCX file format.](https://github.com/alenrajsp/tcxreader)

## License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

## Disclaimer

This framework is provided as-is, and there are no guarantees that it fits your purposes or that it is bug-free. Use it at your own risk!

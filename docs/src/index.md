
# TCXreader.jl Documentation

## Introduction

TCXreader is a Julia package designed for parsing and analyzing Training Center XML (TCX) files. These files are commonly used by sports and fitness devices (like Garmin) to store workout data, including tracks, laps, and physiological metrics.

## Installation

```julia
using Pkg
Pkg.add("TCXreader")
```

## Usage

To use TCXreader, you first need to load the package and then call the `loadTCXFile` function with the path to your TCX file.

```julia
using TCXreader

author, activities = loadTCXFile("path/to/your/file.tcx")
```

```@docs
TCXreader.TCXTrackPoint
```
### `TCXTrackPoint`

- **Description**: Represents a single track point in a TCX file, encapsulating geographical, temporal, and physiological data.
- **Fields**:
  - `time`: The timestamp of the track point.
  - `latitude`: Latitude coordinate (optional).
  - `longitude`: Longitude coordinate (optional).
  - `altitude_meters`: Altitude in meters (optional).
  - `distance_meters`: Cumulative distance in meters (optional).
  - `heart_rate_bpm`: Heart rate in BPM (optional).
  - `speed`: Speed in m/s (optional).

```@docs
TCXreader.TCXLap
```
### `TCXLap`

- **Description**: Represents a single lap within a TCX file, encapsulating temporal, physiological, and spatial metrics.
- **Fields**:
  - `startTime`: Lap's start time.
  - `totalTimeSeconds`: Total time in seconds.
  - `distanceMeters`: Distance in meters.
  - `maximumSpeed`: Maximum speed (optional).
  - `calories`: Calories burned.
  - `averageHeartRateBpm`: Average heart rate (optional).
  - `maximumHeartRateBpm`: Maximum heart rate (optional).
  - `intensity`: Lap intensity.
  - `cadence`: Cadence (optional).
  - `trackPoints`: Vector of `TCXTrackPoint`.
  - `triggerMethod`: Trigger method for the lap.
  - `avgSpeed`: Average speed (optional).

```@docs
TCXreader.TCXActivity
```
### `TCXActivity`

- **Description**: Represents a single activity within a TCX file, including the sport type, activity ID, laps, and device information.
- **Fields**:
  - `sport`: Sport type.
  - `id`: Activity identifier, typically a timestamp.
  - `laps`: Vector of `TCXLap`.
  - `device`: Device information (`DeviceInfo`).

```@docs
TCXreader.DeviceInfo
```
### `DeviceInfo`

- **Description**: Represents the device that recorded the TCX activity, including details such as the name, unit ID, product ID, and version.
- **Fields**:
  - `name`: Device name.
  - `unitId`: Unit ID.
  - `productId`: Product ID.
  - `version`: Device software version.

```@docs
TCXreader.TCXAuthor
TCXreader.BuildVersion
```
### `TCXAuthor`

- **Description**: Represents the author of the TCX file, including the name, software build version, language ID, and part number.
- **Fields**:
  - `name`: Author name.
  - `build`: Software build version (`BuildVersion`).
  - `langID`: Language ID.
  - `partNumber`: Part number.

### Exporting Data

You can also export the loaded TCX data into a CSV file using the `exportCSV` function.

```julia
exportCSV(author, activities, "output_path.csv")
```

For more detailed examples and additional functionality, please refer to the [GitHub repository](https://github.com/firefly-cpp/TCXreader.jl).

## Contributing

Contributions are welcome! Please open an issue or pull request on GitHub if you have suggestions or improvements.

## License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

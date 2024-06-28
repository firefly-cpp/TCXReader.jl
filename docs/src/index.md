# TCXReader.jl Documentation

## Introduction

TCXReader is a Julia package designed for parsing and analyzing Training Center XML (TCX) files. These files are commonly used by sports and fitness devices (like Garmin) to store workout data, including tracks, laps, and physiological metrics.

## Installation

```julia
using Pkg
Pkg.add("TCXReader")
```

## Usage

To use TCXReader, you first need to load the package and then call the `loadTCXFile` function with the path to your TCX file.

```julia
using TCXReader

author, activities = loadTCXFile("path/to/your/file.tcx")
```

## Functions

For detailed documentation on all functions, see [Functions](@ref).

## Types

For detailed documentation on all types, see [Types](@ref).

## Exporting Data

You can also export the loaded TCX data into a CSV file using the `exportCSV` function.

```julia
exportCSV(author, activities, "output_path.csv")
```

For more detailed examples and additional functionality, please refer to the [GitHub repository](https://github.com/firefly-cpp/TCXReader.jl).

## Contributing

Contributions are welcome! Please open an issue or pull request on GitHub if you have suggestions or improvements.

## License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

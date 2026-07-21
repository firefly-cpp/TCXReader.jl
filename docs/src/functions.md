# Functions

## Loading and exporting

```@docs
TCXReader.loadTCXFile
TCXReader.exportCSV
```

## Parsing components

These functions are exported for callers that need to parse an already-open XML document or node. Most applications should use [`loadTCXFile`](@ref).

```@docs
TCXReader.parseTCXAuthor
TCXReader.parseTCXLap
TCXReader.parseTCXTrackPoint
TCXReader.parseDeviceInfo
```

## Aggregation

See [Calculation semantics](@ref) before relying on aggregate fields in downstream analysis.

```@docs
TCXReader.calculate_averages_and_totals
```

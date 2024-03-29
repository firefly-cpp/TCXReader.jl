module Lap

using Dates
using ..TrackPoint: TCXTrackPoint

export TCXLap

"""
Represents a single lap within a TCX file, encapsulating temporal, physiological, and spatial metrics through track points, along with an optional average speed obtained from extensions.

# Parameters
- `startTime`: The lap's start time.
- `totalTimeSeconds`: Total time in seconds.
- `distanceMeters`: Distance in meters.
- `maximumSpeed`: Maximum speed in m/s, optional.
- `calories`: Calories burned.
- `averageHeartRateBpm`: Average heart rate in BPM, optional.
- `maximumHeartRateBpm`: Maximum heart rate in BPM, optional.
- `intensity`: Lap intensity.
- `cadence`: Cadence, optional.
- `trackPoints`: Track points vector.
- `triggerMethod`: Trigger method for the lap.
- `avgSpeed`: Average speed in m/s from `<ns3:AvgSpeed>` extension, optional.
"""
struct TCXLap
    startTime::DateTime
    totalTimeSeconds::Float64
    distanceMeters::Float64
    maximumSpeed::Union{Nothing, Float64}
    calories::Int
    averageHeartRateBpm::Union{Nothing, Int}
    maximumHeartRateBpm::Union{Nothing, Int}
    intensity::String
    cadence::Union{Nothing, Int}
    trackPoints::Vector{TCXTrackPoint}
    triggerMethod::String
    avgSpeed::Union{Nothing, Float64}

    TCXLap() = new(DateTime(1, 1, 1), 0.0, 0.0, nothing, 0, nothing, nothing, "", nothing, Vector{TCXTrackPoint}(), "", nothing)

    TCXLap(startTime::DateTime; totalTimeSeconds::Float64=0.0, distanceMeters::Float64=0.0, maximumSpeed::Union{Nothing, Float64}=nothing,
           calories::Int=0, averageHeartRateBpm::Union{Nothing, Int}=nothing, maximumHeartRateBpm::Union{Nothing, Int}=nothing,
           intensity::String="", cadence::Union{Nothing, Int}=nothing, trackPoints::Vector{TCXTrackPoint}=Vector{TCXTrackPoint}(),
           triggerMethod::String="", avgSpeed::Union{Nothing, Float64}=nothing) =
        new(startTime, totalTimeSeconds, distanceMeters, maximumSpeed, calories, averageHeartRateBpm, maximumHeartRateBpm,
            intensity, cadence, trackPoints, triggerMethod, avgSpeed)
end

function Base.show(io::IO, lap::TCXLap)
    print(io, "TCXLap(StartTime=$(lap.startTime), TotalTimeSeconds=$(lap.totalTimeSeconds), DistanceMeters=$(lap.distanceMeters), MaximumSpeed=$(lap.maximumSpeed), Calories=$(lap.calories), AverageHeartRateBpm=$(lap.averageHeartRateBpm), MaximumHeartRateBpm=$(lap.maximumHeartRateBpm), Intensity=$(lap.intensity), Cadence=$(lap.cadence), AvgSpeed=$(lap.avgSpeed), TrackPoints=[...$(length(lap.trackPoints)) items], TriggerMethod=$(lap.triggerMethod))")
end

end

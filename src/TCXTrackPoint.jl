"""
Represents a single track point in a TCX file, encapsulating geographical, temporal, and physiological data.

# Parameters
- `time`: The timestamp of the track point (required).
- `latitude`: The latitude coordinate of the track point, in degrees (optional).
- `longitude`: The longitude coordinate of the track point, in degrees (optional).
- `altitude_meters`: The altitude of the track point, in meters (optional).
- `distance_meters`: The cumulative distance covered up to this track point, in meters (optional).
- `heart_rate_bpm`: The heart rate at the track point, in beats per minute (optional).
- `cadence`: The cadence at the track point, in revolutions per minute (optional).
- `speed`: The speed at the track point, in meters per second (optional).
- `watts`: The power output at the track point, in watts (optional).
"""
struct TCXTrackPoint
    time::DateTime
    latitude::Union{Nothing, Float64}
    longitude::Union{Nothing, Float64}
    altitude_meters::Union{Nothing, Float64}
    distance_meters::Union{Nothing, Float64}
    heart_rate_bpm::Union{Nothing, Int}
    cadence::Union{Nothing, Int}
    speed::Union{Nothing, Float64}
    watts::Union{Nothing, Int}

    TCXTrackPoint(
        time::DateTime = DateTime(1, 1, 1), 
        latitude::Union{Nothing, Float64} = nothing, 
        longitude::Union{Nothing, Float64} = nothing, 
        altitude_meters::Union{Nothing, Float64} = nothing, 
        distance_meters::Union{Nothing, Float64} = nothing, 
        heart_rate_bpm::Union{Nothing, Int} = nothing,
        cadence::Union{Nothing, Int} = nothing, 
        speed::Union{Nothing, Float64} = nothing,
        watts::Union{Nothing, Int} = nothing
    ) = new(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, cadence, speed, watts)
end

function Base.show(io::IO, tp::TCXTrackPoint)
    print(io, "TCXTrackPoint(time=$(tp.time), latitude=$(tp.latitude), longitude=$(tp.longitude), altitude_meters=$(tp.altitude_meters), distance_meters=$(tp.distance_meters), heart_rate_bpm=$(tp.heart_rate_bpm), cadence=$(tp.cadence), speed=$(tp.speed)), watts=$(tp.watts)")
end

function Base.:(==)(a::TCXTrackPoint, b::TCXTrackPoint)
    return a.time == b.time && a.latitude == b.latitude && a.longitude == b.longitude &&
           a.altitude_meters == b.altitude_meters && a.distance_meters == b.distance_meters &&
           a.heart_rate_bpm == b.heart_rate_bpm && a.cadence == b.cadence && a.speed == b.speed &&
           a.watts == b.watts
end

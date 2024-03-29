module TrackPoint

using Dates

export TCXTrackPoint

"""
    TCXTrackPoint(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)

Represents a single track point with geographical, temporal, and physiological data.
"""
struct TCXTrackPoint
    time::DateTime
    latitude::Union{Nothing, Float64}
    longitude::Union{Nothing, Float64}
    altitude_meters::Union{Nothing, Float64}
    distance_meters::Union{Nothing, Float64}
    heart_rate_bpm::Union{Nothing, Int}
    speed::Union{Nothing, Float64}

    TCXTrackPoint(time::DateTime, latitude::Union{Nothing, Float64}, longitude::Union{Nothing, Float64}, altitude_meters::Union{Nothing, Float64}, distance_meters::Union{Nothing, Float64}, heart_rate_bpm::Union{Nothing, Int}, speed::Union{Nothing, Float64}) =
        new(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)

    TCXTrackPoint() = new(DateTime(1, 1, 1), nothing, nothing, nothing, nothing, nothing, nothing)

    TCXTrackPoint(time::DateTime; latitude=nothing, longitude=nothing, altitude_meters=nothing, distance_meters=nothing, heart_rate_bpm=nothing, speed=nothing) = 
        new(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)
end

function Base.show(io::IO, tp::TCXTrackPoint)
    print(io, "TCXTrackPoint(time=$(tp.time), latitude=$(tp.latitude), longitude=$(tp.longitude), altitude_meters=$(tp.altitude_meters), distance_meters=$(tp.distance_meters), heart_rate_bpm=$(tp.heart_rate_bpm), speed=$(tp.speed))")
end

function Base.:(==)(a::TCXTrackPoint, b::TCXTrackPoint)
    return a.time == b.time && a.latitude == b.latitude && a.longitude == b.longitude &&
           a.altitude_meters == b.altitude_meters && a.distance_meters == b.distance_meters &&
           a.heart_rate_bpm == b.heart_rate_bpm && a.speed == b.speed
end

end

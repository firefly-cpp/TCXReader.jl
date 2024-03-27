module TrackPoint

using Dates

export TCXTrackPoint

struct TCXTrackPoint
    time::DateTime
    latitude::Union{Nothing, Float64}
    longitude::Union{Nothing, Float64}
    altitude_meters::Union{Nothing, Float64}
    distance_meters::Union{Nothing, Float64}
    heart_rate_bpm::Union{Nothing, Int}
    speed::Union{Nothing, Float64}

    # Define a constructor that explicitly accepts all fields with possible Nothing values.
    TCXTrackPoint(time::DateTime, latitude::Union{Nothing, Float64}, longitude::Union{Nothing, Float64}, altitude_meters::Union{Nothing, Float64}, distance_meters::Union{Nothing, Float64}, heart_rate_bpm::Union{Nothing, Int}, speed::Union{Nothing, Float64}) = new(time, latitude, longitude, altitude_meters, distance_meters, heart_rate_bpm, speed)
end

end

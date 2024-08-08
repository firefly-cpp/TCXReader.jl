"""
Represents the device that recorded the TCX activity, encapsulating details such as the name, unit ID, product ID, and version.

# Fields
- `name`: Name of the device.
- `unitId`: Unit ID of the device.
- `productId`: Product ID of the device.
- `version`: Version of the device software.
"""
struct DeviceInfo
    name::String
    unitId::String
    productId::Int
    version::String

    DeviceInfo(name::String="", unitId::String="", productId::Int=0, version::String="") = new(name, unitId, productId, version)
end

function Base.show(io::IO, device::DeviceInfo)
    print(io, "DeviceInfo(Name=$(device.name), UnitId=$(device.unitId), ProductId=$(device.productId), Version=$(device.version))")
end

"""
Represents a single activity within a TCX file, encapsulating the sport type, activity ID, laps, and specific device information, as well as totals and averages for the activity.

# Fields
- `sport`: The sport type of the activity (e.g., Biking).
- `id`: The unique identifier for the activity, typically a timestamp.
- `laps`: A vector of `TCXLap` representing each lap within the activity.
- `device`: Information about the device that recorded the activity, using a `DeviceInfo` struct.
- `total_time`: Total time for the activity.
- `total_distance`: Total distance for the activity.
- `avg_max_speed`: Average maximum speed for the activity.
- `total_calories`: Total calories burned during the activity.
- `avg_avg_hr`: Average heart rate per lap.
- `avg_max_hr`: Average maximum heart rate per lap.
- `avg_cadence`: Average cadence per lap.
- `avg_avg_speed`: Average speed per lap.
"""
struct TCXActivity
    sport::String
    id::DateTime
    laps::Vector{TCXLap}
    device::DeviceInfo
    total_time::Float64
    total_distance::Float64
    avg_max_speed::Float64
    total_calories::Float64
    avg_avg_hr::Float64
    avg_max_hr::Float64
    avg_cadence::Float64
    avg_avg_speed::Float64

    TCXActivity(sport::String="", id::DateTime=DateTime(1, 1, 1), laps::Vector{TCXLap}=Vector{TCXLap}(), device::DeviceInfo=DeviceInfo(), total_time::Float64=0.0, total_distance::Float64=0.0, avg_max_speed::Float64=0.0, total_calories::Float64=0.0, avg_avg_hr::Float64=0.0, avg_max_hr::Float64=0.0, avg_cadence::Float64=0.0, avg_avg_speed::Float64=0.0) = new(sport, id, laps, device, total_time, total_distance, avg_max_speed, total_calories, avg_avg_hr, avg_max_hr, avg_cadence, avg_avg_speed)
end

function Base.show(io::IO, activity::TCXActivity)
    print(io, "TCXActivity(Sport=$(activity.sport), ID=$(activity.id), Laps=[...$(length(activity.laps)) items], Device=$(activity.device), TotalTime=$(activity.total_time), TotalDistance=$(activity.total_distance), AvgMaxSpeed=$(activity.avg_max_speed), TotalCalories=$(activity.total_calories), AvgAvgHR=$(activity.avg_avg_hr), AvgMaxHR=$(activity.avg_max_hr), AvgCadence=$(activity.avg_cadence), AvgAvgSpeed=$(activity.avg_avg_speed))")
end
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
- `max_speed`: Maximum speed achieved during the activity.
- `total_calories`: Total calories burned during the activity.
- `avg_hr`: Average heart rate during the activity.
- `max_hr`: Maximum heart rate achieved during the activity.
- `avg_cadence_zero_avg_on`: Average cadence with zero averaging ON (excluding zeros).
- `avg_cadence_zero_avg_off`: Average cadence with zero averaging OFF (including zeros).
- `max_cadence`: Maximum cadence achieved during the activity.
- `avg_speed`: Average speed during the activity.
- `total_ascent`: Total ascent during the activity.
- `total_descent`: Total descent during the activity.
- `max_altitude`: Maximum altitude reached during the activity.
- `avg_watts_zero_avg_on`: Average power (watts) with zero averaging ON (excluding zeros).
- `avg_watts_zero_avg_off`: Average power (watts) with zero averaging OFF (including zeros).
- `max_watts`: Maximum power (watts) achieved during the activity.
"""
struct TCXActivity
    sport::String
    id::DateTime
    laps::Vector{TCXLap}
    device::DeviceInfo
    total_time::Float64
    total_distance::Float64
    max_speed::Float64
    total_calories::Float64
    avg_hr::Float64
    max_hr::Float64
    avg_cadence_zero_avg_on::Float64
    avg_cadence_zero_avg_off::Float64
    max_cadence::Int
    avg_speed::Float64
    total_ascent::Float64
    total_descent::Float64
    max_altitude::Float64
    avg_watts_zero_avg_on::Float64
    avg_watts_zero_avg_off::Float64
    max_watts::Float64

    TCXActivity(
        sport::String = "",
        id::DateTime = DateTime(1, 1, 1),
        laps::Vector{TCXLap} = Vector{TCXLap}(),
        device::DeviceInfo = DeviceInfo(),
        total_time::Float64 = 0.0,
        total_distance::Float64 = 0.0,
        max_speed::Float64 = 0.0,
        total_calories::Float64 = 0.0,
        avg_hr::Float64 = 0.0,
        max_hr::Float64 = 0.0,
        avg_cadence_zero_avg_on::Float64 = 0.0,
        avg_cadence_zero_avg_off::Float64 = 0.0,
        max_cadence::Int = 0,
        avg_speed::Float64 = 0.0,
        total_ascent::Float64 = 0.0,
        total_descent::Float64 = 0.0,
        max_altitude::Float64 = 0.0,
        avg_watts_zero_avg_on::Float64 = 0.0,
        avg_watts_zero_avg_off::Float64 = 0.0,
        max_watts::Float64 = 0.0
    ) = new(sport, id, laps, device, total_time, total_distance, max_speed, total_calories, avg_hr, max_hr, avg_cadence_zero_avg_on, avg_cadence_zero_avg_off, max_cadence, avg_speed, total_ascent, total_descent, max_altitude, avg_watts_zero_avg_on, avg_watts_zero_avg_off, max_watts)
end

function Base.show(io::IO, activity::TCXActivity)
    print(io, "TCXActivity(Sport=$(activity.sport), ID=$(activity.id), Laps=[...$(length(activity.laps)) items], Device=$(activity.device), TotalTime=$(activity.total_time), TotalDistance=$(activity.total_distance), MaxSpeed=$(activity.max_speed), TotalCalories=$(activity.total_calories), AvgHR=$(activity.avg_hr), MaxHR=$(activity.max_hr), AvgCadenceZeroAvgOn=$(activity.avg_cadence_zero_avg_on), AvgCadenceZeroAvgOff=$(activity.avg_cadence_zero_avg_off), MaxCadence=$(activity.max_cadence), AvgSpeed=$(activity.avg_speed), TotalAscent=$(activity.total_ascent), TotalDescent=$(activity.total_descent), MaxAltitude=$(activity.max_altitude), AvgWattsZeroAvgOn=$(activity.avg_watts_zero_avg_on), AvgWattsZeroAvgOff=$(activity.avg_watts_zero_avg_off), MaxWatts=$(activity.max_watts))")
end

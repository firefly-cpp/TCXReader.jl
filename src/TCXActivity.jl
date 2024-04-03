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
Represents a single activity within a TCX file, encapsulating the sport type, activity ID, laps, and specific device information.

# Fields
- `sport`: The sport type of the activity (e.g., Biking).
- `id`: The unique identifier for the activity, typically a timestamp.
- `laps`: A vector of `TCXLap` representing each lap within the activity.
- `device`: Information about the device that recorded the activity, using a `DeviceInfo` struct.
"""
struct TCXActivity
    sport::String
    id::DateTime
    laps::Vector{TCXLap}
    device::DeviceInfo

    TCXActivity(sport::String="", id::DateTime=DateTime(1, 1, 1), laps::Vector{TCXLap}=Vector{TCXLap}(), device::DeviceInfo=DeviceInfo()) = new(sport, id, laps, device)
end

function Base.show(io::IO, activity::TCXActivity)
    print(io, "TCXActivity(Sport=$(activity.sport), ID=$(activity.id), Laps=[...$(length(activity.laps)) items], Device=$(activity.device))")
end
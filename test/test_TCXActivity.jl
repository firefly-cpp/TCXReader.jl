using Test
using TCXReader
using Dates

@testset "TCXActivity Tests" begin
    activity = TCXActivity(
        "Biking",                     # sport
        DateTime(2021, 1, 1, 12),     # id
        Vector{TCXLap}(),             # laps
        DeviceInfo("Garmin", "123", 456, "1.0"),  # device
        0.0,                          # total_time
        0.0,                          # total_distance
        0.0,                          # max_speed
        0.0,                          # total_calories
        0.0,                          # avg_hr
        0.0,                          # max_hr
        0.0,                          # avg_cadence_zero_avg_on
        0.0,                          # avg_cadence_zero_avg_off
        0,                            # max_cadence (make sure this is an Int)
        0.0,                          # avg_speed
        0.0,                          # total_ascent
        0.0,                          # total_descent
        0.0,                          # max_altitude
        0.0,                          # avg_watts_zero_avg_on
        0.0,                          # avg_watts_zero_avg_off
        0.0                           # max_watts
    )

    @test activity.sport == "Biking"
    @test activity.id == DateTime(2021, 1, 1, 12)
    @test isempty(activity.laps)
    @test activity.device.name == "Garmin"
    @test activity.device.unitId == "123"
    @test activity.device.productId == 456
    @test activity.device.version == "1.0"
    @test activity.total_time == 0.0
    @test activity.total_distance == 0.0
    @test activity.max_speed == 0.0
    @test activity.total_calories == 0.0
    @test activity.avg_hr == 0.0
    @test activity.max_hr == 0.0
    @test activity.avg_cadence_zero_avg_on == 0.0
    @test activity.avg_cadence_zero_avg_off == 0.0
    @test activity.max_cadence == 0
    @test activity.avg_speed == 0.0
    @test activity.total_ascent == 0.0
    @test activity.total_descent == 0.0
    @test activity.max_altitude == 0.0
    @test activity.avg_watts_zero_avg_on == 0.0
    @test activity.avg_watts_zero_avg_off == 0.0
    @test activity.max_watts == 0.0
end

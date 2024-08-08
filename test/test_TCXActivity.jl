using Test
using TCXReader
using Dates

@testset "TCXActivity Tests" begin
    activity = TCXActivity("Biking", DateTime(2021, 1, 1, 12), Vector{TCXLap}(), DeviceInfo("Garmin", "123", 456, "1.0"), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    @test activity.sport == "Biking"
    @test activity.id == DateTime(2021, 1, 1, 12)
    @test isempty(activity.laps)
    @test activity.device.name == "Garmin"
    @test activity.device.unitId == "123"
    @test activity.device.productId == 456
    @test activity.device.version == "1.0"
    @test activity.total_time == 0.0
    @test activity.total_distance == 0.0
    @test activity.avg_max_speed == 0.0
    @test activity.total_calories == 0.0
    @test activity.avg_avg_hr == 0.0
    @test activity.avg_max_hr == 0.0
    @test activity.avg_cadence == 0.0
    @test activity.avg_avg_speed == 0.0
end

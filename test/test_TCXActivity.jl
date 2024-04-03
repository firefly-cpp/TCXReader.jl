using Test
using .TCXreader

@testset "TCXActivity Tests" begin
    activity = TCXActivity("Biking", DateTime(2021, 1, 1, 12), [], DeviceInfo("Garmin", "123", 456, "1.0"))

    @test activity.sport == "Biking"
    @test activity.id == DateTime(2021, 1, 1, 12)
    @test isempty(activity.laps)
    @test activity.device.name == "Garmin"
    @test activity.device.unitId == "123"
    @test activity.device.productId == 456
    @test activity.device.version == "1.0"
end

using Test
using TCXreader
using Dates

@testset "TCXTrackPoint Tests" begin
    tp = TCXTrackPoint(DateTime(2021, 1, 1, 12), 45.0, 13.0, 100.0, 1000.0, 150, 2.5)

    @test tp.time == DateTime(2021, 1, 1, 12)
    @test tp.latitude == 45.0
    @test tp.longitude == 13.0
    @test tp.altitude_meters == 100.0
    @test tp.distance_meters == 1000.0
    @test tp.heart_rate_bpm == 150
    @test tp.speed == 2.5
end

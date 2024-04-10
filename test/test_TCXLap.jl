using Test
using TCXReader
using Dates

@testset "TCXLap Tests" begin
    start_time = DateTime(2021, 1, 1, 12)
    tp = TCXTrackPoint(start_time, 45.0, 13.0, 100.0, 1000.0, 150, 2.5)
    lap = TCXLap(
    start_time, 
    totalTimeSeconds=3600.0, 
    distanceMeters=10000.0, 
    maximumSpeed=5.0, 
    calories=500, 
    averageHeartRateBpm=140, 
    maximumHeartRateBpm=160, 
    intensity="Active", 
    cadence=90, 
    trackPoints=[tp], 
    triggerMethod="Manual", 
    avgSpeed=5.5
)

    @test lap.startTime == start_time
    @test lap.totalTimeSeconds == 3600.0
    @test lap.distanceMeters == 10000.0
    @test lap.maximumSpeed == 5.0
    @test lap.calories == 500
    @test lap.averageHeartRateBpm == 140
    @test lap.maximumHeartRateBpm == 160
    @test lap.intensity == "Active"
    @test lap.cadence == 90
    @test length(lap.trackPoints) == 1
    @test lap.triggerMethod == "Manual"
    @test lap.avgSpeed == 5.5
end

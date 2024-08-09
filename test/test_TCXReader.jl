using Test
using TCXReader
using EzXML
using Dates
using CSV
using DataFrames
using Statistics

@testset "Utility Functions" begin
    @testset "parseOptionalFloat" begin
        xml_doc = parsexml("<root><node>3.14</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXReader.parseOptionalFloat(node, ".") ≈ 3.14
    end

    @testset "parseOptionalInt" begin
        xml_doc = parsexml("<root><node>42</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXReader.parseOptionalInt(node, ".") === 42
    end

    @testset "parseOptionalString" begin
        xml_doc = parsexml("<root><node>hello</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXReader.parseOptionalString(node, ".") === "hello"
    end

    @testset "parseDateTime" begin
        @test TCXReader.parseDateTime("2021-01-01T12:00:00.000Z") === DateTime(2021, 1, 1, 12)
    end
end

@testset "TCX Component Parsing" begin
    xml_str = """
    <TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2">
        <Activities>
            <Activity Sport="Biking">
                <Id>2021-01-01T12:00:00.000Z</Id>
                <Lap StartTime="2021-01-01T12:00:00.000Z">
                    <TotalTimeSeconds>3600</TotalTimeSeconds>
                    <DistanceMeters>10000</DistanceMeters>
                    <Calories>500</Calories>
                    <AverageHeartRateBpm><Value>150</Value></AverageHeartRateBpm>
                    <Track>
                        <Trackpoint>
                            <Time>2021-01-01T12:00:00.000Z</Time>
                            <Position>
                                <LatitudeDegrees>45.0</LatitudeDegrees>
                                <LongitudeDegrees>13.0</LongitudeDegrees>
                            </Position>
                            <AltitudeMeters>100</AltitudeMeters>
                            <DistanceMeters>1000</DistanceMeters>
                            <HeartRateBpm><Value>150</Value></HeartRateBpm>
                            <Cadence>100</Cadence>
                            <Extensions>
                                <ns3:TPX><ns3:Speed>2.5</ns3:Speed></ns3:TPX>
                                <ns3:TPX><ns3:Watts>200</ns3:Watts></ns3:TPX>
                            </Extensions>
                        </Trackpoint>
                    </Track>
                </Lap>
            </Activity>
        </Activities>
        <Author>
            <Name>Garmin Connect API</Name>
            <Build>
                <VersionMajor>17</VersionMajor>
                <VersionMinor>20</VersionMinor>
            </Build>
            <LangID>en</LangID>
            <PartNumber>006-D2449-00</PartNumber>
        </Author>
    </TrainingCenterDatabase>
    """

    doc = parsexml(xml_str)
    root_node = root(doc)

    @testset "parseTCXTrackPoint" begin
        tp_node = findfirst("//g:Trackpoint", root_node, TCXReader.NS_MAP)
        if tp_node !== nothing
            tp = TCXReader.parseTCXTrackPoint(tp_node)
            @test tp.time == DateTime(2021, 1, 1, 12)
            @test tp.latitude ≈ 45.0
            @test tp.longitude ≈ 13.0
            @test tp.altitude_meters ≈ 100.0
            @test tp.distance_meters ≈ 1000.0
            @test tp.heart_rate_bpm === 150
            @test tp.cadence === 100
            @test tp.speed ≈ 2.5
            @test tp.watts === 200
        else
            @test false
        end
    end

    @testset "parseTCXLap" begin
        lap_node = findfirst("//g:Lap", root_node, TCXReader.NS_MAP)
        if lap_node !== nothing
            lap = TCXReader.parseTCXLap(lap_node)
            @test lap.startTime == DateTime(2021, 1, 1, 12)
            @test lap.totalTimeSeconds == 3600
            @test lap.distanceMeters == 10000
            @test lap.calories == 500
            @test length(lap.trackPoints) == 1
        else
            @test false
        end
    end

    @testset "Calculate Averages and Totals" begin
        # Create a set of trackpoints
        trackPoints = [
            TCXTrackPoint(DateTime(2021, 1, 1, 12), 45.0, 13.0, 100.0, 1000.0, 150, 80, 2.5, 200),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 10), 45.1, 13.1, 105.0, 1500.0, 155, 90, 2.6, 210),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 20), 45.2, 13.2, 110.0, 2000.0, 160, 100, 2.7, 220),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 30), 45.3, 13.3, 115.0, 2500.0, 165, 110, 2.8, 230),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 40), 45.4, 13.4, 120.0, 3000.0, 170, 0, 2.9, 240) # Cadence 0 for testing zero averaging
        ]

        # Create a lap
        lap = TCXLap(
            DateTime(2021, 1, 1, 12),
            totalTimeSeconds = 3600.0,
            distanceMeters = 3000.0,
            maximumSpeed = 3.0,
            calories = 500,
            averageHeartRateBpm = 160,
            maximumHeartRateBpm = 170,
            intensity = "Active",
            cadence = 90,
            trackPoints = trackPoints,
            triggerMethod = "Manual",
            avgSpeed = 2.75
        )

        # Calculate averages and totals
        total_time, total_distance, max_speed, total_calories, avg_hr, max_hr, avg_cadence_zero_avg_on, avg_cadence_zero_avg_off, avg_speed, total_ascent, total_descent, max_altitude, avg_watts_zero_avg_on, avg_watts_zero_avg_off, max_watts, max_cadence = TCXReader.calculate_averages_and_totals([lap])

        @test total_time == 3600.0
        @test total_distance == 3000.0
        @test max_speed == 3.0
        @test total_calories == 500.0
        @test avg_hr == 160.0
        @test max_hr == 170.0
        @test avg_cadence_zero_avg_on ≈ 95.0  # Average without considering cadence 0
        @test avg_cadence_zero_avg_off ≈ 76.0  # Average considering cadence 0
        @test avg_speed ≈ 2.7  # Average speed
        @test total_ascent == 20.0  # Ascent from 100m to 120m
        @test total_descent == 0.0  # No descent in this data
        @test max_altitude == 120.0  # Highest altitude
        @test avg_watts_zero_avg_on ≈ 220.0  # Average watts without considering zeros
        @test avg_watts_zero_avg_off ≈ 176.0  # Average watts considering zeros
        @test max_watts == 240.0  # Maximum watts
        @test max_cadence == 110  # Maximum cadence
    end

    @testset "TCXReader Tests -> exportCSV" begin
        author = TCXAuthor("Test Author", BuildVersion(1, 0, 0, 0), "en-US", "000-00000-00")
        trackPoints = [
            TCXTrackPoint(DateTime(2021, 1, 1, 12), 45.0, 13.0, 100.0, 1000.0, 150, 100, 2.5, 200),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 30), 45.1, 13.1, 105.0, 1500.0, 155, 101, 2.6, 201)
        ]
        lap = TCXLap(
            DateTime(2021, 1, 1, 12),
            totalTimeSeconds = 1800.0,
            distanceMeters = 5000.0,
            maximumSpeed = 3.0,
            calories = 250,
            averageHeartRateBpm = 150,
            maximumHeartRateBpm = 160,
            intensity = "Active",
            cadence = 85,
            trackPoints = trackPoints,
            triggerMethod = "Manual",
            avgSpeed = 2.75
        )
        activities = [
            TCXActivity(
                "Biking", DateTime(2021, 1, 1, 12), [lap],
                DeviceInfo("Garmin Edge 530", "123456789", 1, "1.0"),
                1800.0, 5000.0, 3.0, 250.0, 150.0, 160.0, 85.0,
                2.75, 0.0, 0.0, 105.0, 150.0, 200.0, 101.0
            )
        ]

        csv_filepath = "exported_data.csv"

        TCXReader.exportCSV(author, activities, csv_filepath)

        @test isfile(csv_filepath)

        isfile(csv_filepath) && rm(csv_filepath)
    end
end

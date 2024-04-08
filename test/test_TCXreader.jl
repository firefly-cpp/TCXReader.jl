using Test
using TCXreader
using EzXML
using Dates
using CSV
using DataFrames

@testset "Utility Functions" begin
    @testset "parseOptionalFloat" begin
        xml_doc = parsexml("<root><node>3.14</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXreader.parseOptionalFloat(node, ".") ≈ 3.14
    end

    @testset "parseOptionalInt" begin
        xml_doc = parsexml("<root><node>42</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXreader.parseOptionalInt(node, ".") === 42
    end

    @testset "parseOptionalString" begin
        xml_doc = parsexml("<root><node>hello</node></root>")
        node = findfirst("//node", xml_doc)
        @test TCXreader.parseOptionalString(node, ".") === "hello"
    end

    @testset "parseDateTime" begin
        @test TCXreader.parseDateTime("2021-01-01T12:00:00.000Z") === DateTime(2021, 1, 1, 12)
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
                            <Extensions>
                                <ns3:TPX><ns3:Speed>2.5</ns3:Speed></ns3:TPX>
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
        tp_node = findfirst("//g:Trackpoint", root_node, TCXreader.NS_MAP)
        if tp_node !== nothing
            tp = TCXreader.parseTCXTrackPoint(tp_node)
            @test tp.time == DateTime(2021, 1, 1, 12)
            @test tp.latitude ≈ 45.0
            @test tp.longitude ≈ 13.0
            @test tp.altitude_meters ≈ 100.0
            @test tp.distance_meters ≈ 1000.0
            @test tp.heart_rate_bpm === 150
            @test tp.speed ≈ 2.5
        else
            @test false
        end
    end

    @testset "parseTCXLap" begin
        lap_node = findfirst("//g:Lap", root_node, TCXreader.NS_MAP)
        if lap_node !== nothing
            lap = TCXreader.parseTCXLap(lap_node)
            @test lap.startTime == DateTime(2021, 1, 1, 12)
            @test lap.totalTimeSeconds == 3600
            @test lap.distanceMeters == 10000
            @test lap.calories == 500
            @test length(lap.trackPoints) == 1
        else
            @test false
        end
    end

    #    @testset "parseTCXAuthor" begin
    #        author = TCXreader.parseTCXAuthor(doc)
    #        @test author.name == "Garmin Connect API"
    #        @test author.build.versionMajor == 17
    #        @test author.build.versionMinor == 20
    #        @test author.langID == "en"
    #        @test author.partNumber == "006-D2449-00"
    #    end

    @testset "TCXreader Tests - exportCSV" begin

        author = TCXAuthor("Test Author", BuildVersion(1, 0, 0, 0), "en-US", "000-00000-00")
        trackPoints = [
            TCXTrackPoint(DateTime(2021, 1, 1, 12), 45.0, 13.0, 100.0, 1000.0, 150, 2.5),
            TCXTrackPoint(DateTime(2021, 1, 1, 12, 30), 45.1, 13.1, 105.0, 1500.0, 155, 2.6)
        ]
        lap = TCXLap(DateTime(2021, 1, 1, 12), totalTimeSeconds=1800.0, distanceMeters=5000.0, maximumSpeed=3.0, calories=250, averageHeartRateBpm=150, maximumHeartRateBpm=160, intensity="Active", cadence=85, trackPoints=trackPoints, triggerMethod="Manual", avgSpeed=2.75)
        activities = [TCXActivity("Biking", DateTime(2021, 1, 1, 12), [lap], DeviceInfo("Garmin Edge 530", "123456789", 1, "1.0"))]

        csv_filepath = "exported_data.csv"

        TCXreader.exportCSV(author, activities, csv_filepath)

        @test isfile(csv_filepath)

        isfile(csv_filepath) && rm(csv_filepath)

    end

end

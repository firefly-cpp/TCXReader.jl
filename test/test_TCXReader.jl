using Test
using TCXreader
using EzXML
using Dates
using TCXTrackPoint

@testset "TCXReader Parsing Tests" begin
    @testset "parseTCXTrackPoint" begin
        xml_str = """
        <Trackpoint>
            <Time>2021-01-01T12:00:00.000Z</Time>
            <Position>
                <LatitudeDegrees>45.0</LatitudeDegrees>
                <LongitudeDegrees>13.0</LongitudeDegrees>
            </Position>
            <AltitudeMeters>100.0</AltitudeMeters>
            <DistanceMeters>1000.0</DistanceMeters>
            <HeartRateBpm>
                <Value>150</Value>
            </HeartRateBpm>
            <Extensions>
                <TPX xmlns="http://www.garmin.com/xmlschemas/ActivityExtension/v2">
                    <Speed>2.5</Speed>
                </TPX>
            </Extensions>
        </Trackpoint>
        """
        doc = parsexml(xml_str)
        tp_node = findfirst("//Trackpoint", doc)
        tp = parseTCXTrackPoint(tp_node)

        @test tp.time == DateTime(2021, 1, 1, 12)
        @test tp.latitude == 45.0
        @test tp.longitude == 13.0
        @test tp.altitude_meters == 100.0
        @test tp.distance_meters == 1000.0
        @test tp.heart_rate_bpm == 150
        @test tp.speed == 2.5
    end
end

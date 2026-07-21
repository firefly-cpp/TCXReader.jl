using Test
using TCXReader
using CSV
using Dates
using EzXML

const MODERN_TCX_XML = """
<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2">
  <Activities>
    <Activity Sport="Biking">
      <Id>2024-04-05T12:30:00.123456+02:30</Id>
      <Lap>
        <Track>
          <Trackpoint>
            <Time>2024-04-05T10:00:00Z</Time>
            <Extensions>
              <ns3:TPX><ns3:Speed>2.5</ns3:Speed></ns3:TPX>
              <ns3:TPX><ns3:Watts>200</ns3:Watts></ns3:TPX>
            </Extensions>
          </Trackpoint>
        </Track>
      </Lap>
      <Creator>
        <Name>First Device</Name>
      </Creator>
    </Activity>
    <Activity Sport="Running">
      <Creator>
        <Name>Second Device</Name>
        <UnitId>unit-2</UnitId>
        <ProductID>9</ProductID>
        <Version><VersionMajor>2</VersionMajor><VersionMinor>5</VersionMinor></Version>
      </Creator>
    </Activity>
  </Activities>
  <Author>
    <Build><Version><VersionMajor>7</VersionMajor></Version></Build>
  </Author>
</TrainingCenterDatabase>
"""

function with_modern_tcx(f::Function, xml::String=MODERN_TCX_XML)
    mktemp() do path, stream
        write(stream, xml)
        close(stream)
        return f(path)
    end
end

module ReaderDemoExample
include(joinpath(@__DIR__, "..", "examples", "reader_demo.jl"))
end

@testset "v0.3.0 modernization" begin
    @testset "ISO-8601 timestamps" begin
        @test TCXReader.parseDateTime("") == DateTime(1, 1, 1)
        @test TCXReader.parseDateTime("2024-01-02T03:04:05Z") == DateTime(2024, 1, 2, 3, 4, 5)
        @test TCXReader.parseDateTime("2024-01-02T03:04:05") == DateTime(2024, 1, 2, 3, 4, 5)
        @test TCXReader.parseDateTime("2024-01-02T03:04:05.1Z") == DateTime(2024, 1, 2, 3, 4, 5, 100)
        @test TCXReader.parseDateTime("2024-01-02T03:04:05.123987Z") == DateTime(2024, 1, 2, 3, 4, 5, 123)
        @test TCXReader.parseDateTime("2024-01-01T00:15:00+02:30") == DateTime(2023, 12, 31, 21, 45)
        @test TCXReader.parseDateTime("2024-01-01T00:15:00-01:15") == DateTime(2024, 1, 1, 1, 30)
        @test TCXReader.parseDateTime("2024-01-01T14:00:00+14:00") == DateTime(2024, 1, 1)
        @test_throws ArgumentError TCXReader.parseDateTime("not-a-timestamp")
        @test_throws ArgumentError TCXReader.parseDateTime("2024-01-01T00:00:00+24:00")
        @test_throws ArgumentError TCXReader.parseDateTime("2024-01-01T00:00:00+14:01")
    end

    @testset "sparse metadata and activity-local creators" begin
        with_modern_tcx() do path
            author, activities = loadTCXFile(path)

            @test author.name == ""
            @test author.langID == ""
            @test author.partNumber == ""
            @test author.build == BuildVersion(7, 0, 0, 0)
            @test length(activities) == 2

            first_activity, second_activity = activities
            @test first_activity.id == DateTime(2024, 4, 5, 10, 0, 0, 123)
            @test first_activity.device == DeviceInfo("First Device", "", 0, "")
            @test length(first_activity.laps) == 1
            @test first_activity.laps[1].startTime == DateTime(1, 1, 1)
            @test first_activity.laps[1].totalTimeSeconds == 0.0
            @test first_activity.laps[1].distanceMeters == 0.0
            @test first_activity.laps[1].calories == 0
            @test first_activity.laps[1].cadence === nothing
            @test only(first_activity.laps[1].trackPoints).speed == 2.5
            @test only(first_activity.laps[1].trackPoints).watts == 200

            @test second_activity.id == DateTime(1, 1, 1)
            @test second_activity.device == DeviceInfo("Second Device", "unit-2", 9, "2.5")
            @test isempty(second_activity.laps)
        end
    end

    @testset "missing Activities" begin
        xml = """
        <TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
          <Author><Name>Minimal Author</Name></Author>
        </TrainingCenterDatabase>
        """
        with_modern_tcx(xml) do path
            author, activities = loadTCXFile(path)
            @test author.name == "Minimal Author"
            @test isempty(activities)
        end
    end

    @testset "invalid metadata still errors" begin
        bad_author = parsexml("""
        <TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
          <Author><Build><Version><VersionMajor>bad</VersionMajor></Version></Build></Author>
        </TrainingCenterDatabase>
        """)
        @test_throws ArgumentError parseTCXAuthor(bad_author)

        bad_lap = parsexml("""
        <Lap xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
          <TotalTimeSeconds>bad</TotalTimeSeconds>
        </Lap>
        """)
        @test_throws ArgumentError parseTCXLap(root(bad_lap))

        bad_device_xml = replace(MODERN_TCX_XML, "<ProductID>9</ProductID>" => "<ProductID>bad</ProductID>")
        with_modern_tcx(bad_device_xml) do path
            @test_throws ArgumentError loadTCXFile(path)
        end
    end

    @testset "malformed trackpoints are skipped" begin
        trackpoint_doc = parsexml("""
        <Trackpoint xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
          <Time>bad</Time>
        </Trackpoint>
        """)
        @test_logs (:warn, r"Error parsing trackpoint:.*Skipping this trackpoint") begin
            @test parseTCXTrackPoint(root(trackpoint_doc)) === nothing
        end
    end

    @testset "trackpoint display and hashing" begin
        trackpoint = TCXTrackPoint(DateTime(2024, 1, 1), 1.0, 2.0, 3.0, 4.0, 100, 80, 5.0, 200)
        equal_trackpoint = TCXTrackPoint(DateTime(2024, 1, 1), 1.0, 2.0, 3.0, 4.0, 100, 80, 5.0, 200)

        @test trackpoint == equal_trackpoint
        @test hash(trackpoint) == hash(equal_trackpoint)
        @test length(Set([trackpoint, equal_trackpoint])) == 1
        @test sprint(show, trackpoint) == "TCXTrackPoint(time=2024-01-01T00:00:00, latitude=1.0, longitude=2.0, altitude_meters=3.0, distance_meters=4.0, heart_rate_bpm=100, cadence=80, speed=5.0, watts=200)"
    end

    @testset "CSV schema" begin
        expected_columns = [
            :AuthorName,
            :AuthorBuildVersion,
            :AuthorLangID,
            :AuthorPartNumber,
            :ActivitySport,
            :ActivityID,
            :DeviceName,
            :DeviceVersion,
            :LapNumber,
            :StartTime,
            :TotalTimeSeconds,
            :DistanceMeters,
            :Calories,
            :AverageHR,
            :MaximumHR,
            :Intensity,
            :TrackPointTime,
            :Latitude,
            :Longitude,
            :AltitudeMeters,
            :DistanceMetersTP,
            :HeartRateBpm,
            :Cadence,
            :Speed,
            :Watts,
        ]

        with_modern_tcx() do tcx_path
            author, activities = loadTCXFile(tcx_path)
            mktemp() do csv_path, stream
                close(stream)
                exportCSV(author, activities, csv_path; io=IOBuffer())
                table = CSV.File(csv_path)
                @test propertynames(table) == expected_columns
                @test length(table) == 1
            end
        end
    end

    @testset "CLI" begin
        @test :_cli_main ∉ names(TCXReader)

        output = IOBuffer()
        errors = IOBuffer()
        @test TCXReader._cli_main(String[], output, errors) == 0
        @test occursin("Usage:", String(take!(output)))
        @test isempty(String(take!(errors)))

        @test TCXReader._cli_main(["--version"], output, errors) == 0
        @test occursin("TCXReader 0.3.0", String(take!(output)))

        @test TCXReader._cli_main(["--unknown"], output, errors) == 2
        @test occursin("unknown option", String(take!(errors)))

        @test TCXReader._cli_main(["--csv"], output, errors) == 2
        @test occursin("requires an output path", String(take!(errors)))

        mktempdir() do directory
            @test TCXReader._cli_main([joinpath(directory, "missing.tcx")], output, errors) == 1
            @test occursin("Error:", String(take!(errors)))
        end

        with_modern_tcx() do tcx_path
            @test TCXReader._cli_main([tcx_path], output, errors) == 0
            summary = String(take!(output))
            @test occursin("Author: unknown", summary)
            @test occursin("Activities: 2", summary)
            @test occursin("Activity 1", summary)
            @test occursin("ID: unknown", summary)
            @test occursin("Device: First Device", summary)
            @test occursin("Duration:", summary)
            @test occursin("Heart rate:", summary)
            @test occursin("Elevation:", summary)
            @test occursin("Power:", summary)
            @test isempty(String(take!(errors)))

            mktemp() do csv_path, stream
                close(stream)
                @test TCXReader._cli_main(["--csv", csv_path, tcx_path], output, errors) == 0
                @test isfile(csv_path)
                @test length(CSV.File(csv_path)) == 1
                @test occursin("Exported complete TCX data", String(take!(output)))
                @test isempty(String(take!(errors)))
            end
        end

        with_modern_tcx("<not-closed>") do path
            @test TCXReader._cli_main([path], output, errors) == 1
            @test occursin("Error:", String(take!(errors)))
        end
    end

    @testset "bundled TCX files" begin
        repository_root = normpath(joinpath(@__DIR__, ".."))
        for filename in ("15.tcx", "23.tcx")
            author, activities = loadTCXFile(joinpath(repository_root, "example_data", filename))
            @test author.name == "Garmin Connect API"
            @test !isempty(activities)
            @test !isempty(first(activities).device.name)
            @test !isempty(first(activities).laps)
            @test !isempty(first(first(activities).laps).trackPoints)
        end
    end

    @testset "bundled example" begin
        redirect_stdout(devnull) do
            @test ReaderDemoExample.main() === nothing
        end
    end
end

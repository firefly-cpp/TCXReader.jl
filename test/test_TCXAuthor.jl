using Test
using TCXReader

@testset "TCXAuthor Tests" begin
    author = TCXAuthor("Test Author", BuildVersion(1, 2, 3, 4), "EN", "123456")

    @test author.name == "Test Author"
    @test author.build.versionMajor == 1
    @test author.build.versionMinor == 2
    @test author.build.buildMajor == 3
    @test author.build.buildMinor == 4
    @test author.langID == "EN"
    @test author.partNumber == "123456"
end

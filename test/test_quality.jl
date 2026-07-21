using Aqua
using TCXReader

@testset "Package quality" begin
    Aqua.test_all(TCXReader)
end

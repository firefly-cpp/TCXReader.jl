using Documenter
using TCXReader

makedocs(
    modules=[TCXReader],
    clean=true,
    format=Documenter.HTML(),
    sitename="TCXReader.jl Documentation",
    pages=[
        "Home" => "index.md",
        "Functions" => "functions.md",
        "Types" => "types.md"
    ]
)


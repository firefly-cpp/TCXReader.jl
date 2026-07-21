using Documenter
using TCXReader

DocMeta.setdocmeta!(
    TCXReader,
    :DocTestSetup,
    :(using TCXReader);
    recursive=true,
)

makedocs(
    modules=[TCXReader],
    clean=true,
    doctest=true,
    checkdocs=:exports,
    warnonly=false,
    format=Documenter.HTML(
        canonical="https://firefly-cpp.github.io/TCXReader.jl",
        edit_link="main",
        prettyurls=get(ENV, "CI", "false") == "true",
    ),
    sitename="TCXReader.jl Documentation",
    pages=[
        "Home" => "index.md",
        "Using TCXReader" => "usage.md",
        "Calculation semantics" => "calculations.md",
        "API reference" => [
            "Functions" => "functions.md",
            "Types" => "types.md",
        ],
    ],
)

deploydocs(
    repo="github.com/firefly-cpp/TCXReader.jl.git",
    devbranch="main",
)

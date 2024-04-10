using Documenter
using TCXReader

makedocs(
    sitename = "TCXReader",
    format = Documenter.HTML(),
    modules = [TCXReader],
    pages = [
        "Home" => "index.md",
    ]
)


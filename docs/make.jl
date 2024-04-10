using Documenter
using TCXreader

makedocs(
    sitename = "TCXreader",
    format = Documenter.HTML(),
    modules = [TCXreader],
    pages = [
        "Home" => "index.md",
    ]
)


using VulkanExperiments
using Documenter

makedocs(;
    modules=[VulkanExperiments],
    authors="Bradley Lyman <lyman.brad3211@gmail.com> and contributors",
    repo="https://github.com/BradLyman/VulkanExperiments.jl/blob/{commit}{path}#L{line}",
    sitename="VulkanExperiments.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://BradLyman.github.io/VulkanExperiments.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Drawing A Triangle" => [
            "DrawingATriangle/0_Setup.md",
            "DrawingATriangle/1_Instance.md",
        ],
        "Index" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/BradLyman/VulkanExperiments.jl",
    devbranch="main"
)

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
    ],
)

deploydocs(;
    repo="github.com/BradLyman/VulkanExperiments.jl",
    devbranch="main"
)

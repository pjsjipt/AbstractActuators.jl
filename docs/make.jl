using AbstractMover
using Documenter

DocMeta.setdocmeta!(AbstractMover, :DocTestSetup, :(using AbstractMover); recursive=true)

makedocs(;
    modules=[AbstractMover],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/AbstractMover.jl/blob/{commit}{path}#{line}",
    sitename="AbstractMover.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

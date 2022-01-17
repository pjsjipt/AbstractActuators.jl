using AbstractActuators
using Documenter

DocMeta.setdocmeta!(AbstractActuators, :DocTestSetup, :(using AbstractActuators); recursive=true)

makedocs(;
    modules=[AbstractActuator],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/AbstractActuators.jl/blob/{commit}{path}#{line}",
    sitename="AbstractActuators.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

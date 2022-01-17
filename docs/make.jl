using AbstractActuator
using Documenter

DocMeta.setdocmeta!(AbstractActuator, :DocTestSetup, :(using AbstractActuator); recursive=true)

makedocs(;
    modules=[AbstractActuator],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/AbstractActuator.jl/blob/{commit}{path}#{line}",
    sitename="AbstractActuator.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

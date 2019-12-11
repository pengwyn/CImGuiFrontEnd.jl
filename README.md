# CImGuiFrontEnd.jl
A convenient front-end for CImGui.jl

Currently hardcoded to work on my linux machine only with GLFW.

Includes a wrapper around the init-gui loop-shutdown cycle, as well as several convenience context wrappers.

Check out the CImGui example (requires CSyntax):

```julia
using CImGuiFrontEnd
include(joinpath(dirname(pathof(CImGuiFrontEnd)), "..", "examples", "orig_demo.jl"))
```

and the context wrappers:

```julia
using CImGuiFrontEnd
include(joinpath(dirname(pathof(CImGuiFrontEnd)), "..", "examples", "context_wrappers.jl"))
```

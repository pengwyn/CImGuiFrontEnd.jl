
include(joinpath(dirname(pathof(CImGui)), "..", "examples", "demo_window.jl"))

DoGui(() -> ShowDemoWindow(Ref(true)))

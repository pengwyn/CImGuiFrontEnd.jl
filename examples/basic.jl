
using Printf

# This is a copy paste from the examples in CImGui

function TestFunc(clear_color=copy(CImGuiFrontEnd.default_clear_color))
    @cstatic show_demo_window=false show_another_window=false begin
        # show a simple window that we create ourselves.
        # we use a Begin/End pair to created a named window.
        @cstatic f=Cfloat(0.0) counter=Cint(0) begin
            CImGui.Begin("Hello, world!")  # create a window called "Hello, world!" and append into it.
            CImGui.Text("This is some useful text.")  # display some text
            @c CImGui.Checkbox("Demo Windows", &show_demo_window)  # edit bools storing our window open/close state
            @c CImGui.Checkbox("Another Window", &show_another_window)

            @c CImGui.SliderFloat("float", &f, 0, 1)  # edit 1 float using a slider from 0 to 1
            CImGui.ColorEdit3("clear color", clear_color)  # edit 3 floats representing a color
            CImGui.Button("Button") && (counter += 1)

            CImGui.SameLine()
            CImGui.Text("counter = $counter")
            CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / CImGui.GetIO().Framerate, CImGui.GetIO().Framerate))

            CImGui.End()
        end

        # show another simple window.
        if show_another_window
            @c CImGui.Begin("Another Window", &show_another_window)  # pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            CImGui.Text("Hello from another window!")
            CImGui.Button("Close Me") && (show_another_window = false;)
            CImGui.End()
        end

        if show_demo_window
            CImGui.ShowStyleSelector("asdf")
            CImGui.Begin("asdf2")
            CImGui.ShowStyleEditor()
            CImGui.End()
            CImGui.ShowFontSelector("asdf3")
        end
    end


end

DoGui(TestFunc)

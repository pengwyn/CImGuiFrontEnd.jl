
G = CImGui

using Printf

DoGui() do
    @cstatic f=Cfloat(0.0) counter=Cint(0) one=false two=false clear_color=copy(CImGuiFrontEnd.default_clear_color) begin
        G.Begin("Hello, world!")  # create a window called "Hello, world!" and append into it.

        TreeNode("First section") do
            G.Text("This is some useful text.")  # display some text
            TreeNode("Secret") do
                G.Text("Not really...")
            end
            TreeNode("Even more secret") do
                G.Text("Nothing to see here")
            end
        end
        WithColumns(2, ["A", "B"]) do
            @c G.Checkbox("Column 1 Box", &one)  # edit bools storing our window open/close state
            G.NextColumn()
            @c G.Checkbox("Column 2 Box", &two)  # edit bools storing our window open/close state
        end

        @SameLine begin
            G.Text("testing")
            G.Button("Button") && (counter += 1)
            G.Text("counter = $counter")
            @c G.Checkbox("Something", &two)
            G.Text("$one $two")
        end

        WithStyleColors(G.ImGuiCol_Text => G.HSV(0.0, 0.9, 0.8)) do
            G.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / G.GetIO().Framerate, G.GetIO().Framerate))
        end


        G.End()

    end


end

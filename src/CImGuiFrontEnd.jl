module CImGuiFrontEnd

export DoGui

# Utils
export TreeNode,
    WithColumns,
    WithStyleColors,
    @SameLine


using Reexport
using ArgCheck

@reexport using CImGui
# @reexport using CImGui.CSyntax
# @reexport using CImGui.CSyntax.CStatic
using CImGui.GLFWBackend
using CImGui.OpenGLBackend
using CImGui.GLFWBackend.GLFW
using CImGui.OpenGLBackend.ModernGL

g_glfw_window = nothing

const default_clear_color = Cfloat[0.45, 0.55, 0.60, 1.00]

function DoGui(func ; width=1280, height=720,
               name="Demo",
               clear_color=default_clear_color, style=:light,
               vsync=true,
               ini_filename=C_NULL)
    # OpenGL 3.0 + GLSL 130
    glsl_version = 130
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 0)
    # GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE) # 3.2+ only
    # GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE) # 3.0+ only

    # setup GLFW error callback
    error_callback(err::GLFW.GLFWError) = @error "GLFW ERROR: code $(err.code) msg: $(err.description)"
    GLFW.SetErrorCallback(error_callback)

    # create window
    window = GLFW.CreateWindow(width, height, name)
    @assert window != C_NULL
    GLFW.MakeContextCurrent(window)

    vsync && GLFW.SwapInterval(1)

    # setup Dear ImGui context
    ctx = CImGui.CreateContext()

    # setup Dear ImGui style
    if style == :dark
        CImGui.StyleColorsDark()
    elseif style == :classic
        CImGui.StyleColorsClassic()
    elseif style == :light
        CImGui.StyleColorsLight()
    else
        error("Unknown style $style")
    end

    # setup Platform/Renderer bindings
    ImGui_ImplGlfw_InitForOpenGL(window, true)
    ImGui_ImplOpenGL3_Init(glsl_version)

    io = CImGui.GetIO()
    io.IniFilename = ini_filename
    
    try
        while !GLFW.WindowShouldClose(window)
            GLFW.PollEvents()
            # start the Dear ImGui frame
            ImGui_ImplOpenGL3_NewFrame()
            ImGui_ImplGlfw_NewFrame()
            CImGui.NewFrame()

            global g_glfw_window = window
            func()

            # rendering
            CImGui.Render()

            GLFW.MakeContextCurrent(window)
            display_w, display_h = GLFW.GetFramebufferSize(window)
            glViewport(0, 0, display_w, display_h)
            glClearColor(clear_color...)
            glClear(GL_COLOR_BUFFER_BIT)

            ImGui_ImplOpenGL3_RenderDrawData(CImGui.GetDrawData())

            GLFW.MakeContextCurrent(window)
            GLFW.SwapBuffers(window)

            yield()
        end
    finally
        # cleanup
        ImGui_ImplOpenGL3_Shutdown()
        ImGui_ImplGlfw_Shutdown()
        CImGui.DestroyContext(ctx)

        GLFW.DestroyWindow(window)
    end
end

##############################
# * Utils
#----------------------------
FrameSize(window=g_glfw_window) = GLFW.GetFramebufferSize(window)


######################################
# * Context wrappers
#------------------------------------

"""
    TreeNode(func, name)
    TreeNode(func, name, always_after)

Intended to be used as `TreeNode("label") do ... end`

The second form allows for extra commands to be given in `always_after` which will
occur immediately after the call to `CImGui.TreeNode`. This is necessary when
using other features such as overlays or drag and drop.
"""
function TreeNode(func, name, always_after=()->nothing)
    ret = CImGui.TreeNode(name)
    always_after()
    if ret
        func()
        CImGui.TreePop()
    end
end

function WithColumns(func, num, headings=nothing, widths=nothing ; separator=true, end_separator=separator)
    CImGui.Columns(num)

    if headings != nothing
        widths == nothing && (widths = fill(nothing, num))

        @argcheck length(headings) == num
        for (heading,width) in zip(headings,widths)
            CImGui.Text(heading)

            cur_width = CImGui.GetColumnWidth()
            width == :min && (width = CImGui.GetItemRectSize().x)
            width != nothing && width < cur_width && CImGui.SetColumnWidth(-1, width)

            CImGui.NextColumn()
        end
    end
    separator && CImGui.Separator()

    func()

    CImGui.Columns(1)
    end_separator && CImGui.Separator()
end

function WithStyleColors(func, args::Pair...)
    for (name,col) in args
        CImGui.PushStyleColor(name, col)
    end

    func()

    CImGui.PopStyleColor(length(args))
end


##########################################
# * Other useful tools
#----------------------------------------

"""
    @SameLine block

Places `CImGui.SameLine()` after every statement, except for the last.
"""
macro SameLine(ex)
    @argcheck ex.head == :block

    old_args = ex.args

    ex.args = Expr[]

    last = true

    for item in reverse(old_args)
        if !isa(item, LineNumberNode)
            !last && pushfirst!(ex.args, :(CImGui.SameLine()))
            last = false
        end
        pushfirst!(ex.args, item)
    end

    ex.args = esc.(ex.args)
    ex
end


end

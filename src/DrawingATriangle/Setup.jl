"""
    Setup

This module is the first step in getting started with Vulkan. It's purpose is
to create a window using GLFW which supports Vulkan.
"""
module Setup

export main

using GLFW

"""
    main()

The application's entry point.
"""
main() = (
    buildApp()
    |> initWindow
    |> initVulkan
    |> mainLoop
    |> cleanup
)

"""
The application's state. Anything the main app needs to run will be included
here.
"""
Base.@kwdef mutable struct App
    window::Union{Some{GLFW.Window}, Nothing}
end

"""
Construct a new application instance.
"""
function buildApp()
    App(;
        window = nothing
    )
end

"""
    initWindow(app::App) :: App

Create the application's main window. Configure to support Vulkan instead of
OpenGL.
"""
function initWindow(app::App) :: App
    # NO_API disables GLFW's attempt to load an OpenGL context
    GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)

    # Resizing takes extra management, so don't support it for now
    GLFW.WindowHint(GLFW.RESIZABLE, false)

    app.window = GLFW.CreateWindow(800, 600, "Vulkan") |> Some

    app
end

"""
    initVulkan(app::App) :: App

Initialize Vulkan resources for this application.
"""
function initVulkan(app::App) :: App
    app
end

"""
    mainLoop(app::App) :: App

The application's main loop. This function blocks until the window is closed
by clicking the 'x' or similarly exited.
"""
function mainLoop(app::App) :: App
    window = something(app.window)

    while !GLFW.WindowShouldClose(window)
        GLFW.PollEvents()
    end

    app
end

"""
    cleanup(app::App) :: App

Cleanup any and all graphical resources.
"""
function cleanup(app::App) :: App
    app.window |> something |> GLFW.DestroyWindow
    app.window = nothing
    app
end

end # End Setup Module

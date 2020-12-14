"""
    Instance

This module is the second step for getting started with Vulkan. It's purpose is
to create a window with a Vulkan instance.

See https://vulkan-tutorial.com/en/Drawing_a_triangle/Setup/Instance
"""
module Instance

export main

using GLFW
using VulkanCore
using VulkanCore.LibVulkan

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
    instance::Ref{VkInstance}
end

"""
Construct a new application instance.
"""
function buildApp()
    App(;
        window = nothing,
        instance = Ref(C_NULL)
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

    # Create an AppInfo struct instance on the heap.
    #
    # Q: Why not just on the stack then Ref it on demand?
    # A: Because this struct is not passed directly into a function. Instead,
    #    the pointer to this struct is saved in the InstanceCreateInfo struct.
    #    This means the location must not change during the subsequent calls.
    appInfoRef = begin
        sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
        pNext = C_NULL
        pApplicationName = pointer("Vulkan Demo")
        applicationVersion = VK_MAKE_VERSION(1, 0, 0)
        pEngineName = pointer("No Engine")
        engineVersion = VK_MAKE_VERSION(1, 0, 0)
        apiVersion = VK_API_VERSION_1_2
        VkApplicationInfo(
            sType,
            pNext,
            pApplicationName,
            applicationVersion,
            pEngineName,
            engineVersion,
            apiVersion
        ) |> Ref
    end

    # Note the usage of `GC.@preserve` to ensure that AppInfo doesn't get GC'd
    # or moved between the creation of the InstanceCreateInfo struct and the
    # call to vkCreateInstance.
    result = GC.@preserve appInfoRef begin
        createInfo = begin
            sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
            pNext = C_NULL
            flags = UInt32(0)
            pApplicationInfo =
                Base.unsafe_convert(Ptr{VkApplicationInfo}, appInfoRef)
            enabledExtensionCount = UInt32(0)
            ppEnabledExtensionNames =
                GLFW.GetRequiredInstanceExtensions(Ref(enabledExtensionCount))
            enabledLayerCount = UInt32(0)
            ppEnabledLayerNames = C_NULL
            VkInstanceCreateInfo(
                sType,
                pNext,
                flags,
                pApplicationInfo,
                enabledLayerCount,
                ppEnabledLayerNames,
                enabledExtensionCount,
                ppEnabledExtensionNames
            )
        end

        vkCreateInstance(Ref(createInfo), C_NULL, app.instance)
    end

    if result == VK_SUCCESS
        @info "successfully created vulkan instance"
    else
        error("Unable to create a vulkan instance")
    end

    # Get supported extensions

    # First get the number of extensions
    # Note the usage of ref to get mutable data under the pointer
    refCount = Ref(Cuint(0))
    vkEnumerateInstanceExtensionProperties(C_NULL, refCount, C_NULL)

    # Now get the actual extensions
    extensions = Vector{VkExtensionProperties}(undef, refCount[])
    vkEnumerateInstanceExtensionProperties(
        C_NULL, refCount, pointer(extensions))

    to_string(name) = rstrip(name |> collect |> String, '\0')
    names = [e.extensionName |> to_string for e in extensions]
    @info "supported extensions $names"

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

    # the second argument is for custom allocator callbacks
    vkDestroyInstance(app.instance[], C_NULL)

    app.window |> something |> GLFW.DestroyWindow
    app.window = nothing
    app
end

end # End Instance Module

"""
    ValidationLayers

This module is the second step for getting started with Vulkan. It's purpose is
to create a window with a Vulkan instance.

See https://vulkan-tutorial.com/Drawing_a_triangle/Setup/Validation_layers
"""
module ValidationLayers

export main

using GLFW
using VulkanCore
using VulkanCore.LibVulkan

"""
    main()

The application's entry point.
"""
main(debug=true) = (
    buildApp(debug)
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
    debug::Bool
end

"""
Construct a new application instance.
"""
function buildApp(debug::Bool)
    App(;
        window = nothing,
        instance = Ref(C_NULL),
        debug = debug
    )
end

"""
    initWindow(app::App) :: App

Create the application's main window. Configure to support Vulkan instead of
OpenGL.
"""
function initWindow(app::App) :: App
    GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
    GLFW.WindowHint(GLFW.RESIZABLE, false)
    app.window = GLFW.CreateWindow(800, 600, "Vulkan") |> Some

    app
end

"""
    initVulkan(app::App) :: App

Initialize Vulkan resources for this application.
"""
function initVulkan(app::App) :: App

    appInfoRef = buildAppInfo()
    createVulkanInstance(appInfoRef, app.debug, app.instance)

    app
end

"""
    buildAppInfo :: Ref{VkApplicationInfo}

Create an instance of the application info structure, using the correct
application name and vulkan versions.
"""
function buildAppInfo() :: Ref{VkApplicationInfo}
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

to_string_pp(names::Vector{String}) =
    Base.unsafe_convert(Ref{Cstring}, Base.cconvert(Ref{Cstring}, names))

"""
    createVulkanInstance(
        appInfo::Ref{VkApplicationInfo},
        instance::Ref{VkInstance}
    )

Create the vulkan instance for this application.
"""
function createVulkanInstance(
    appInfo::Ref{VkApplicationInfo},
    debug::Bool,
    instance::Ref{VkInstance}
)
    debugLayers :: Vector{String} = ["VK_LAYER_KHRONOS_validation"]

    # Check that the debug layers are available if debug is enabled
    if debug
        availableLayers = supportedLayers()
        @info "All supported layers \n$(join(availableLayers, '\n'))"
        if !issubset(debugLayers, availableLayers)
            error("requested debug layers are not available!")
        end
    end

    @info "All supported extensions \n$(join(supportedExtensions(), '\n'))"

    result = GC.@preserve appInfo begin
        sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
        pNext = C_NULL
        flags = UInt32(0)
        pApplicationInfo = Base.unsafe_convert(Ptr{VkApplicationInfo}, appInfo)
        enabledExtensionCount = UInt32(0)
        ppEnabledExtensionNames =
            GLFW.GetRequiredInstanceExtensions(Ref(enabledExtensionCount))

        enabledLayerCount::UInt32 = debug ? length(debugLayers) : UInt32(0)
        ppEnabledLayerNames = debug ? debugLayers |> to_string_pp : C_NULL

        instanceCreateInfo = VkInstanceCreateInfo(
            sType,
            pNext,
            flags,
            pApplicationInfo,
            enabledLayerCount,
            ppEnabledLayerNames,
            enabledExtensionCount,
            ppEnabledExtensionNames
        )

        vkCreateInstance(Ref(instanceCreateInfo), C_NULL, instance)
    end

    if result == VK_SUCCESS
        @info "successfully created vulkan instance"
    else
        error("Unable to create a vulkan instance")
    end
end

"""
    supportedExtensions() :: Vector{String}

Fetch a vector of all supported extension names.
"""
function supportedExtensions() :: Vector{String}
    # First get the number of extensions
    refCount = Ref(Cuint(0))
    vkEnumerateInstanceExtensionProperties(C_NULL, refCount, C_NULL)

    # Now get the actual extensions
    extensions = Vector{VkExtensionProperties}(undef, refCount[])
    vkEnumerateInstanceExtensionProperties(
        C_NULL, refCount, pointer(extensions))

    # Get the extension names as strings
    [rstrip(e.extensionName |> collect |> String, '\0') for e in extensions]
end

"""
    supportedLayers() :: Vector{String}

Fetch a vector of all supported layer names.
"""
function supportedLayers() :: Vector{String}
    # First get the number of layers
    refCount = Ref(Cuint(0))
    vkEnumerateInstanceLayerProperties(refCount, C_NULL)

    # Now get the actual layers
    layers = Vector{VkLayerProperties}(undef, refCount[])
    vkEnumerateInstanceLayerProperties(refCount, pointer(layers))

    # Get the layer names as strings
    [rstrip(l.layerName |> collect |> String, '\0') for l in layers]
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

end # End ValidationLayers Module

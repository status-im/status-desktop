#include "StatusQ/graphicsapiselection.h"

namespace GraphicsApiSelection {

Decision decide(const Environment& env, const std::function<VulkanProbe()>& probeVulkan)
{
    if (!env.rhiBackend.isEmpty() || !env.quickBackend.isEmpty())
        return {Api::QtDefault, "environment override"};

    if (env.androidSdk < MinVulkanAndroidSdk)
        return {Api::QtDefault, "Android version too old for Vulkan"};

    const VulkanProbe probe = probeVulkan();
    if (!probe.deviceCreated)
        return {Api::QtDefault, "Vulkan device creation failed"};
    if (probe.apiVersion < MinVulkanApiVersion)
        return {Api::QtDefault, "Vulkan version too old"};

    return {Api::Vulkan, "device supported"};
}

} // namespace GraphicsApiSelection

#include "StatusQ/graphicsapiselection.h"

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QQuickWindow>
#include <QVulkanFunctions>
#include <QVulkanInstance>
#include <rhi/qrhi.h>

#include <memory>

using namespace GraphicsApiSelection;

namespace {

// Qt Quick has no fallback once a Vulkan QRhi fails to create, so prove the
// device first the same way the scene graph will create it.
VulkanProbe probeVulkan(QByteArray& deviceName)
{
    QVulkanInstance instance;
    if (!instance.create())
        return {};

    VulkanProbe result;
    QVulkanFunctions* f = instance.functions();
    uint32_t count = 1;
    VkPhysicalDevice physicalDevice = VK_NULL_HANDLE;
    const VkResult err = f->vkEnumeratePhysicalDevices(instance.vkInstance(), &count, &physicalDevice);
    if ((err == VK_SUCCESS || err == VK_INCOMPLETE) && count > 0) {
        VkPhysicalDeviceProperties props{};
        f->vkGetPhysicalDeviceProperties(physicalDevice, &props);
        result.apiVersion = props.apiVersion;
        deviceName = props.deviceName;
    }

    QRhiVulkanInitParams params;
    params.inst = &instance;
    std::unique_ptr<QRhi> rhi(QRhi::create(QRhi::Vulkan, &params));
    result.deviceCreated = rhi != nullptr;
    return result;
}

} // namespace

extern "C" Q_DECL_EXPORT void statusq_selectGraphicsApi()
{
    QElapsedTimer timer;
    timer.start();

    QByteArray deviceName;
    const Environment env{qgetenv("QSG_RHI_BACKEND"), qgetenv("QT_QUICK_BACKEND"),
                          QNativeInterface::QAndroidApplication::sdkVersion()};
    const Decision decision = decide(env, [&deviceName] { return probeVulkan(deviceName); });

    if (decision.api == Api::Vulkan)
        QQuickWindow::setGraphicsApi(QSGRendererInterface::Vulkan);

    qWarning("Qt Quick graphics API: %s (%s%s%s) in %lld ms",
             decision.api == Api::Vulkan ? "Vulkan" : "Qt default", decision.reason,
             deviceName.isEmpty() ? "" : ", ", deviceName.constData(), timer.elapsed());
}

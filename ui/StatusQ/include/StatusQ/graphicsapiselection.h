#pragma once

#include <QByteArray>
#include <QtGlobal>

#include <functional>

namespace GraphicsApiSelection {

// Vulkan drivers before Android 10 are too often broken to default to.
constexpr int MinVulkanAndroidSdk = 29;
// VK_MAKE_API_VERSION(0, 1, 1, 0), mandatory for Vulkan devices on Android 10+.
constexpr quint32 MinVulkanApiVersion = (1u << 22) | (1u << 12);

enum class Api {
    QtDefault, // leave the choice to Qt (env override or its platform default)
    Vulkan
};

struct Environment {
    QByteArray rhiBackend;   // QSG_RHI_BACKEND
    QByteArray quickBackend; // QT_QUICK_BACKEND
    int androidSdk = 0;
};

struct VulkanProbe {
    bool deviceCreated = false; // a QRhi Vulkan device could be created
    quint32 apiVersion = 0;     // VkPhysicalDeviceProperties::apiVersion
};

struct Decision {
    Api api = Api::QtDefault;
    const char* reason = "";
};

// The probe is only run when its result can change the decision.
Decision decide(const Environment& env, const std::function<VulkanProbe()>& probeVulkan);

} // namespace GraphicsApiSelection

#ifdef Q_OS_ANDROID
extern "C" {

// Requests Vulkan for Qt Quick when the device supports it, else keeps Qt's
// default (OpenGL ES). Call after QGuiApplication, before the first window.
Q_DECL_EXPORT void statusq_selectGraphicsApi();

}
#endif

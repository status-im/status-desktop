#pragma once

#include <QByteArray>
#include <QVersionNumber>
#include <QtGlobal>

#include <functional>

namespace GraphicsApiSelection {

// Vulkan drivers before Android 10 are too often broken to default to.
constexpr int MinVulkanAndroidSdk = 29;
// VK_MAKE_API_VERSION(0, 1, 1, 0), mandatory for Vulkan devices launching with Android 10+.
constexpr quint32 MinVulkanApiVersion = (1u << 22) | (1u << 12);

enum class Api {
    QtDefault, // leave the choice to Qt (env override or its platform default)
    Vulkan
};

// Persisted across starts. A Vulkan start stays Pending until its window
// presents a frame, so a Pending one found at startup never did.
struct VulkanHistory {
    enum class State { None, Pending, Failed };

    State state = State::None;
    QByteArray appVersion; // the version that attempted (Pending) or failed (Failed)
};

QByteArray serialize(const VulkanHistory& history);
VulkanHistory parseHistory(const QByteArray& data);

struct Environment {
    QByteArray rhiBackend;   // QSG_RHI_BACKEND
    QByteArray quickBackend; // QT_QUICK_BACKEND
    int androidSdk = 0;
    QByteArray appVersion;
    VulkanHistory history;
};

struct VulkanProbe {
    bool androidSurface = false; // VK_KHR_android_surface is available
    bool deviceCreated = false;  // a QRhi Vulkan device could be created
    quint32 apiVersion = 0;      // VkPhysicalDeviceProperties::apiVersion
};

struct Decision {
    Api api = Api::QtDefault;
    const char* reason = "";
    VulkanHistory history; // to persist before the first window is created
};

// The instance API version Qt's QVulkanDefaultInstance requests for the
// given vkEnumerateInstanceVersion() result; null means leave it at 1.0.
QVersionNumber instanceApiVersion(const QVersionNumber& supported);

// The probe is only run when its result can change the decision. A Vulkan
// start that never presented a frame keeps that app version on Qt's default;
// the next app version tries Vulkan again.
Decision decide(const Environment& env, const std::function<VulkanProbe()>& probeVulkan);

} // namespace GraphicsApiSelection

#ifdef Q_OS_ANDROID
extern "C" {

// Requests Vulkan for Qt Quick when the device supports it and Vulkan has not
// failed on this app version, else keeps Qt's default (OpenGL ES). `engine` is
// the QQmlApplicationEngine whose first window confirms Vulkan works. Call
// after QGuiApplication, before the first window.
Q_DECL_EXPORT void statusq_selectGraphicsApi(void* engine);

}
#endif

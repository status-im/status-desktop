#include "StatusQ/graphicsapiselection.h"

#include <QCoreApplication>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QSaveFile>
#include <QStandardPaths>
#include <QVulkanFunctions>
#include <QVulkanInstance>
#include <rhi/qrhi.h>

#include <memory>

using namespace GraphicsApiSelection;

namespace {

QString historyPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
           + QStringLiteral("/vulkan-history");
}

VulkanHistory readHistory(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return {};
    return parseHistory(file.readAll());
}

bool writeHistory(const QString& path, const VulkanHistory& history)
{
    if (history.state == VulkanHistory::State::None)
        return !QFile::exists(path) || QFile::remove(path);

    QDir().mkpath(QFileInfo(path).absolutePath());
    QSaveFile file(path);
    return file.open(QIODevice::WriteOnly) && file.write(serialize(history)) >= 0 && file.commit();
}

// Qt Quick has no fallback once a Vulkan QRhi fails to create, so prove the
// device first the way QVulkanDefaultInstance and the scene graph create it.
VulkanProbe probeVulkan(QByteArray& deviceName)
{
    VulkanProbe result;
    QVulkanInstance instance;
    result.androidSurface = instance.supportedExtensions().contains("VK_KHR_android_surface");
    if (!result.androidSurface)
        return result;

    const QVersionNumber apiVersion = instanceApiVersion(instance.supportedApiVersion());
    if (!apiVersion.isNull())
        instance.setApiVersion(apiVersion);
    instance.setExtensions(QRhiVulkanInitParams::preferredInstanceExtensions());
    if (!instance.create())
        return result;

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
    result.deviceCreated = QRhi::probe(QRhi::Vulkan, &params);
    return result;
}

// The first presented frame of the first window proves Vulkan works; a start
// that never gets there leaves the Pending record for the next start to find.
void clearHistoryOnFirstFrame(QQmlApplicationEngine* engine, const QString& path)
{
    auto connection = std::make_shared<QMetaObject::Connection>();
    *connection = QObject::connect(
        engine, &QQmlApplicationEngine::objectCreated, engine,
        [connection, path](QObject* object) {
            auto window = qobject_cast<QQuickWindow*>(object);
            if (!window)
                return;
            QObject::disconnect(*connection);
            // Emitted on the render thread
            QObject::connect(
                window, &QQuickWindow::frameSwapped, window,
                [path] {
                    if (!writeHistory(path, {}))
                        qWarning("Could not clear %s", qPrintable(path));
                },
                Qt::ConnectionType(Qt::DirectConnection | Qt::SingleShotConnection));
        });
}

} // namespace

extern "C" Q_DECL_EXPORT void statusq_selectGraphicsApi(void* engine)
{
    QElapsedTimer timer;
    timer.start();

    const QString path = historyPath();
    QByteArray deviceName;
    const Environment env{qgetenv("QSG_RHI_BACKEND"), qgetenv("QT_QUICK_BACKEND"),
                          QNativeInterface::QAndroidApplication::sdkVersion(),
                          QCoreApplication::applicationVersion().toUtf8(), readHistory(path)};
    Decision decision = decide(env, [&deviceName] { return probeVulkan(deviceName); });

    if (!writeHistory(path, decision.history) && decision.api == Api::Vulkan)
        decision = {Api::QtDefault, "Vulkan start could not be recorded", {}};

    if (decision.api == Api::Vulkan) {
        QQuickWindow::setGraphicsApi(QSGRendererInterface::Vulkan);
        // Qt's MediaCodec frames are attached to a GL external texture, which
        // fails under Vulkan, and their CPU readback shows a frozen frame on
        // some decoders; FFmpeg's software decoders work with any API.
        if (!qEnvironmentVariableIsSet("QT_FFMPEG_DECODING_HW_DEVICE_TYPES"))
            qputenv("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", ",");
        clearHistoryOnFirstFrame(static_cast<QQmlApplicationEngine*>(engine), path);
    }

    qInfo("Qt Quick graphics API: %s (%s%s%s) in %lld ms",
          decision.api == Api::Vulkan ? "Vulkan" : "Qt default", decision.reason,
          deviceName.isEmpty() ? "" : ", ", deviceName.constData(), timer.elapsed());
}

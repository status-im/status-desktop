#include "StatusQ/graphicsapiselection.h"

#include <QList>

namespace GraphicsApiSelection {

namespace {

constexpr char PendingTag[] = "pending";
constexpr char FailedTag[] = "failed";

} // namespace

QByteArray serialize(const VulkanHistory& history)
{
    switch (history.state) {
    case VulkanHistory::State::Pending:
        return PendingTag + QByteArray("\n") + history.appVersion + '\n';
    case VulkanHistory::State::Failed:
        return FailedTag + QByteArray("\n") + history.appVersion + '\n';
    case VulkanHistory::State::None:
        break;
    }
    return {};
}

VulkanHistory parseHistory(const QByteArray& data)
{
    const QList<QByteArray> lines = data.trimmed().split('\n');
    if (lines.size() != 2 || lines[1].trimmed().isEmpty())
        return {};

    const QByteArray tag = lines[0].trimmed();
    if (tag == PendingTag)
        return {VulkanHistory::State::Pending, lines[1].trimmed()};
    if (tag == FailedTag)
        return {VulkanHistory::State::Failed, lines[1].trimmed()};
    return {};
}

QVersionNumber instanceApiVersion(const QVersionNumber& supported)
{
    for (const int minor : {4, 3, 2, 1}) {
        if (supported >= QVersionNumber(1, minor))
            return QVersionNumber(1, minor);
    }
    return {};
}

Decision decide(const Environment& env, const std::function<VulkanProbe()>& probeVulkan)
{
    VulkanHistory history = env.history;
    if (history.state == VulkanHistory::State::Pending)
        history.state = VulkanHistory::State::Failed;

    if (!env.rhiBackend.isEmpty() || !env.quickBackend.isEmpty())
        return {Api::QtDefault, "environment override", history};

    if (env.androidSdk < MinVulkanAndroidSdk)
        return {Api::QtDefault, "Android version too old for Vulkan", history};

    if (history.state == VulkanHistory::State::Failed && history.appVersion == env.appVersion)
        return {Api::QtDefault, "Vulkan presented no frame on this app version before", history};

    const VulkanProbe probe = probeVulkan();
    if (!probe.androidSurface)
        return {Api::QtDefault, "no Vulkan Android surface support", history};
    if (!probe.deviceCreated)
        return {Api::QtDefault, "Vulkan device creation failed", history};
    if (probe.apiVersion < MinVulkanApiVersion)
        return {Api::QtDefault, "Vulkan version too old", history};

    return {Api::Vulkan, "device supported", {VulkanHistory::State::Pending, env.appVersion}};
}

} // namespace GraphicsApiSelection

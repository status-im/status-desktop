#include <QTest>

#include <StatusQ/graphicsapiselection.h>

using namespace GraphicsApiSelection;

namespace {

constexpr int Android10 = 29;
constexpr quint32 Vulkan1_0 = 1u << 22;
constexpr quint32 Vulkan1_1 = (1u << 22) | (1u << 12);
constexpr quint32 Vulkan1_3 = (1u << 22) | (3u << 12);

using State = VulkanHistory::State;

const VulkanProbe Capable{true, true, Vulkan1_3};

struct ProbeSpy {
    VulkanProbe result;
    int calls = 0;

    std::function<VulkanProbe()> fn()
    {
        return [this] {
            ++calls;
            return result;
        };
    }
};

Environment androidEnv(VulkanHistory history = {})
{
    return {{}, {}, Android10, "2.40.0", history};
}

} // namespace

class tst_GraphicsApiSelection : public QObject
{
    Q_OBJECT

private slots:
    void rhiBackendEnv_leavesChoiceToQt_withoutProbing()
    {
        ProbeSpy probe{Capable};

        const auto d = decide({"opengl", {}, Android10, "2.40.0", {}}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void quickBackendEnv_leavesChoiceToQt_withoutProbing()
    {
        ProbeSpy probe{Capable};

        const auto d = decide({{}, "software", Android10, "2.40.0", {}}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void androidBefore10_keepsQtDefault_withoutProbing()
    {
        ProbeSpy probe{Capable};
        Environment env = androidEnv();
        env.androidSdk = 28;

        const auto d = decide(env, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void noAndroidSurfaceExtension_fallsBackToQtDefault()
    {
        ProbeSpy probe{{false, true, Vulkan1_3}};

        const auto d = decide(androidEnv(), probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
    }

    void vulkanDeviceCreationFails_fallsBackToQtDefault()
    {
        ProbeSpy probe{{true, false, Vulkan1_3}};

        const auto d = decide(androidEnv(), probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 1);
        QCOMPARE(d.history.state, State::None);
    }

    void vulkan1_0Device_fallsBackToQtDefault()
    {
        ProbeSpy probe{{true, true, Vulkan1_0}};

        const auto d = decide(androidEnv(), probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
    }

    void vulkan1_1Device_onAndroid10_selectsVulkan_andMarksItPending()
    {
        ProbeSpy probe{{true, true, Vulkan1_1}};

        const auto d = decide(androidEnv(), probe.fn());

        QCOMPARE(d.api, Api::Vulkan);
        QCOMPARE(probe.calls, 1);
        QCOMPARE(d.history.state, State::Pending);
        QCOMPARE(d.history.appVersion, "2.40.0");
    }

    void pendingFromPreviousStart_keepsQtDefault_andRecordsTheFailure_withoutProbing()
    {
        ProbeSpy probe{Capable};

        const auto d = decide(androidEnv({State::Pending, "2.40.0"}), probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
        QCOMPARE(d.history.state, State::Failed);
        QCOMPARE(d.history.appVersion, "2.40.0");
    }

    void failedOnThisVersion_staysOnQtDefault_withoutProbing()
    {
        ProbeSpy probe{Capable};

        const auto d = decide(androidEnv({State::Failed, "2.40.0"}), probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
        QCOMPARE(d.history.state, State::Failed);
    }

    void failedOnOlderVersion_triesVulkanAgain()
    {
        ProbeSpy probe{Capable};

        const auto d = decide(androidEnv({State::Failed, "2.39.1"}), probe.fn());

        QCOMPARE(d.api, Api::Vulkan);
        QCOMPARE(d.history.state, State::Pending);
        QCOMPARE(d.history.appVersion, "2.40.0");
    }

    void pendingFromOlderVersion_triesVulkanAgain()
    {
        ProbeSpy probe{Capable};

        const auto d = decide(androidEnv({State::Pending, "2.39.1"}), probe.fn());

        QCOMPARE(d.api, Api::Vulkan);
        QCOMPARE(d.history.state, State::Pending);
        QCOMPARE(d.history.appVersion, "2.40.0");
    }

    void envOverride_stillRecordsAPendingStartAsFailed()
    {
        ProbeSpy probe{Capable};
        Environment env = androidEnv({State::Pending, "2.40.0"});
        env.rhiBackend = "opengl";

        const auto d = decide(env, probe.fn());

        QCOMPARE(d.history.state, State::Failed);
        QCOMPARE(d.history.appVersion, "2.40.0");
    }

    void history_roundTrips()
    {
        for (const VulkanHistory h : {VulkanHistory{State::Pending, "2.40.0"},
                                      VulkanHistory{State::Failed, "2.39.1-12-gabc"}}) {
            const VulkanHistory parsed = parseHistory(serialize(h));
            QCOMPARE(parsed.state, h.state);
            QCOMPARE(parsed.appVersion, h.appVersion);
        }
    }

    void history_unreadable_isNone()
    {
        QCOMPARE(parseHistory({}).state, State::None);
        QCOMPARE(parseHistory("garbage").state, State::None);
        QCOMPARE(parseHistory("pending").state, State::None);
    }

    void instanceApiVersion_followsQtsDefaultInstanceLadder()
    {
        QCOMPARE(instanceApiVersion(QVersionNumber(1, 0, 61)), QVersionNumber());
        QCOMPARE(instanceApiVersion(QVersionNumber(1, 1, 128)), QVersionNumber(1, 1));
        QCOMPARE(instanceApiVersion(QVersionNumber(1, 3, 250)), QVersionNumber(1, 3));
        QCOMPARE(instanceApiVersion(QVersionNumber(1, 5)), QVersionNumber(1, 4));
    }
};

QTEST_GUILESS_MAIN(tst_GraphicsApiSelection)
#include "tst_graphicsapiselection.moc"

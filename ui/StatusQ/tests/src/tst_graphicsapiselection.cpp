#include <QTest>

#include <StatusQ/graphicsapiselection.h>

using namespace GraphicsApiSelection;

namespace {

constexpr int Android10 = 29;
constexpr quint32 Vulkan1_0 = 1u << 22;
constexpr quint32 Vulkan1_1 = (1u << 22) | (1u << 12);
constexpr quint32 Vulkan1_3 = (1u << 22) | (3u << 12);

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

} // namespace

class tst_GraphicsApiSelection : public QObject
{
    Q_OBJECT

private slots:
    void rhiBackendEnv_leavesChoiceToQt_withoutProbing()
    {
        ProbeSpy probe{{true, Vulkan1_3}};

        const auto d = decide({"opengl", {}, Android10}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void quickBackendEnv_leavesChoiceToQt_withoutProbing()
    {
        ProbeSpy probe{{true, Vulkan1_3}};

        const auto d = decide({{}, "software", Android10}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void androidBefore10_keepsQtDefault_withoutProbing()
    {
        ProbeSpy probe{{true, Vulkan1_3}};

        const auto d = decide({{}, {}, 28}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 0);
    }

    void vulkanDeviceCreationFails_fallsBackToQtDefault()
    {
        ProbeSpy probe{{false, Vulkan1_3}};

        const auto d = decide({{}, {}, Android10}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
        QCOMPARE(probe.calls, 1);
    }

    void vulkan1_0Device_fallsBackToQtDefault()
    {
        ProbeSpy probe{{true, Vulkan1_0}};

        const auto d = decide({{}, {}, Android10}, probe.fn());

        QCOMPARE(d.api, Api::QtDefault);
    }

    void vulkan1_1Device_onAndroid10_selectsVulkan()
    {
        ProbeSpy probe{{true, Vulkan1_1}};

        const auto d = decide({{}, {}, Android10}, probe.fn());

        QCOMPARE(d.api, Api::Vulkan);
        QCOMPARE(probe.calls, 1);
    }
};

QTEST_GUILESS_MAIN(tst_GraphicsApiSelection)
#include "tst_graphicsapiselection.moc"

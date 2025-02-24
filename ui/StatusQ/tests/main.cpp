#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
#include <QtWebEngine>
#else
#include <QtWebEngineQuick>
#endif

#include <TestHelpers/MonitorQtOutput.h>
#include <TestHelpers/modelaccessobserverproxy.h>

#include <StatusQ/typesregistration.h>

class RunBeforeQApplicationIsInitialized {
public:
    RunBeforeQApplicationIsInitialized()
    {
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        QtWebEngine::initialize();
#else
        QtWebEngineQuick::initialize();
#endif
    }
};

static RunBeforeQApplicationIsInitialized runBeforeQApplicationIsInitialized;

class TestSetup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        engine->addImportPath(QStringLiteral(STATUSQ_MODULE_IMPORT_PATH));
        engine->addImportPath(QStringLiteral(QUICK_TEST_SOURCE_DIR) + "/qml/");

        // TODO: Alternative to not yet supported QML_ELEMENT
        qmlRegisterType<MonitorQtOutput>("StatusQ.TestHelpers", 0, 1, "MonitorQtOutput");
        qmlRegisterType<ModelAccessObserverProxy>("StatusQ.TestHelpers", 0, 1, "ModelAccessObserverProxy");

        registerStatusQTypes();
    }
};

QUICK_TEST_MAIN_WITH_SETUP(TestStatusQ, TestSetup)

#include "main.moc"

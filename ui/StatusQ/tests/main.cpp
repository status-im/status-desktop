#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

#include <QtWebEngine>

#include "TestHelpers/MonitorQtOutput.h"
#include "TestHelpers/modelaccessobserverproxy.h"

class RunBeforeQApplicationIsInitialized {
public:
    RunBeforeQApplicationIsInitialized()
    {
        QtWebEngine::initialize();
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
    }
};

QUICK_TEST_MAIN_WITH_SETUP(TestStatusQ, TestSetup)

#include "main.moc"

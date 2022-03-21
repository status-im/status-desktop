#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

#include "TestHelpers/MonitorQtOutput.h"

class TestSetup : public QObject
{
    Q_OBJECT

public:
    TestSetup() {}

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        // TODO: Workaround until we make StatusQ a CMake library
        engine->addImportPath("../../src/");
        engine->addImportPath(".");
        // TODO: Alternative to not yet supported QML_ELEMENT
        qmlRegisterType<MonitorQtOutput>("StatusQ.TestHelpers", 0, 1, "MonitorQtOutput");
    }
private:
    MonitorQtOutput _monitorOutput;
};

QUICK_TEST_MAIN_WITH_SETUP(TestControls, TestSetup)

#include "main.moc"

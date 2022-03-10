#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

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
    }
};

QUICK_TEST_MAIN_WITH_SETUP(TestControls, TestSetup)

#include "main.moc"

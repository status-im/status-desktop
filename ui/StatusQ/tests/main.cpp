#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

#include "TestHelpers/MonitorQtOutput.h"

class TestSetup : public QObject
{
    Q_OBJECT

public:
    TestSetup() {}

public slots:

    void importStatusQPlugin(QQmlEngine *engine) {
        QList<QQmlError> loadErrors;
        const auto pluginPath = QStringLiteral(STATUSQ_MODULE_PATH) + "/StatusQ";

        if (!engine->importPlugin(pluginPath, "StatusQ", &loadErrors))
            qWarning() << "Failed to load StatusQ plugin";

        for (const auto& error : loadErrors)
            qWarning() << error;
    };

    void qmlEngineAvailable(QQmlEngine *engine)
    {
        engine->addImportPath(QStringLiteral(STATUSQ_MODULE_IMPORT_PATH));
        engine->addImportPath(QStringLiteral(QUICK_TEST_SOURCE_DIR) + "/qml/");

        // Force import StatusQ plugin to load all StatusQ resources
        importStatusQPlugin(engine);

        // TODO: Alternative to not yet supported QML_ELEMENT
        qmlRegisterType<MonitorQtOutput>("StatusQ.TestHelpers", 0, 1, "MonitorQtOutput");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(TestControls, TestSetup)

#include "main.moc"

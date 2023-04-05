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
        engine->addImportPath(QStringLiteral(":/"));
        qDebug() << QGuiApplication::applicationDirPath();
        qDebug() << engine->importPathList();
//
//        QList<QQmlError> loadErrors;
//        qDebug() << engine->importPlugin(QGuiApplication::applicationDirPath() + "/StatusQ/libStatusQ.dylib", "StatusQ", &loadErrors);
//
//        for (const auto& error : loadErrors)
//            qWarning() << error;

        // TODO: Alternative to not yet supported QML_ELEMENT
        qmlRegisterType<MonitorQtOutput>("StatusQ.TestHelpers", 0, 1, "MonitorQtOutput");
    }
};

QUICK_TEST_MAIN_WITH_SETUP(TestControls, TestSetup)

#include "main.moc"

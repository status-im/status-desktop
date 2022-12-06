#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        // custom code that needs QQmlEngine, register QML types, add import paths,...
        const QStringList additionalImportPaths {
            QML_IMPORT_ROOT + QStringLiteral("/../ui/StatusQ/src"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
            QML_IMPORT_ROOT + QStringLiteral("/stubs"),
            QML_IMPORT_ROOT + QStringLiteral("/mocks"),
        };

        for (const auto& path : additionalImportPaths)
            engine->addImportPath(path);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(QmlTests, Setup)

#include "main.moc"

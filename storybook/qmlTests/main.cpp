#include <QQmlEngine>
#include <QtQuickTest>

#include "src/TextUtils.h"

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        // custom code that needs QQmlEngine, register QML types, add import paths,...
        const QStringList additionalImportPaths {
            STATUSQ_MODULE_IMPORT_PATH,
            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
            QML_IMPORT_ROOT + QStringLiteral("/stubs"),
            QML_IMPORT_ROOT + QStringLiteral("/src")
        };

        for (const auto& path : additionalImportPaths)
            engine->addImportPath(path);

        qmlRegisterSingletonType<TextUtils>("TextUtils", 1, 0, "TextUtils", &TextUtils::qmlInstance);

        QStandardPaths::setTestModeEnabled(true);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(QmlTests, Setup)

#include "main.moc"

#include <QQmlEngine>
#include <QtQuickTest>

#include <StatusQ/typesregistration.h>

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        // custom code that needs QQmlEngine, register QML types, add import paths,...

        QGuiApplication::setOrganizationName(QStringLiteral("Status"));
        QGuiApplication::setOrganizationDomain(QStringLiteral("status.im"));

        qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));
        
        const QStringList additionalImportPaths {
            STATUSQ_MODULE_IMPORT_PATH,
            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/StatusQ/tests/qml"),
            QML_IMPORT_ROOT + QStringLiteral("/stubs"),
            QML_IMPORT_ROOT + QStringLiteral("/src")
        };

        for (const auto& path : additionalImportPaths)
            engine->addImportPath(path);

        registerStatusQTypes();

        QStandardPaths::setTestModeEnabled(true);

        QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedStates));
    }
};

QUICK_TEST_MAIN_WITH_SETUP(QmlTests, Setup)

#include "main.moc"

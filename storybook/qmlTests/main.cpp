#include <QQmlEngine>
#include <QtQuickTest>

#include <StatusQ/typesregistration.h>

using namespace Qt::Literals::StringLiterals;

class Setup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine) {
        Q_INIT_RESOURCE(storybook);

        QGuiApplication::setOrganizationName(u"Status"_s);
        QGuiApplication::setOrganizationDomain(u"status.im"_s);

        qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", "1"_ba);
        
        const QStringList additionalImportPaths {
            STATUSQ_MODULE_IMPORT_PATH,
            u"qrc:/"_s,
            QML_IMPORT_ROOT u"/../ui/app"_s,
            QML_IMPORT_ROOT u"/../ui/imports"_s,
            QML_IMPORT_ROOT u"/../ui/StatusQ/tests/qml"_s,
            QML_IMPORT_ROOT u"/stubs"_s,
            QML_IMPORT_ROOT u"/src"_s
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

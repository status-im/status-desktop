#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>

#include <Helpers/helpers.h>
#include <Helpers/logs.h>

#include <QDir>
#include <QDebug>

using namespace Status;

void setApplicationInformation(QGuiApplication& app);

int main(int argc, char *argv[])
{
    //qInstallMessageHandler(Helpers::logFormatter);

    QGuiApplication app(argc, argv);
    
    setApplicationInformation(app);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = BUILD_PROJECT_NAME + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;

    const QUrl url(u"qrc:/Status/Application/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

void setApplicationInformation(QGuiApplication& app) {
#if !defined BUILD_PROJECT_ORGANIZATION_NAME
    static_assert(false, "Compile-time define missing: BUILD_PROJECT_ORGANIZATION_NAME")
#endif
    app.setOrganizationName(BUILD_PROJECT_ORGANIZATION_NAME);
#if !defined BUILD_PROJECT_ORGANIZATION_DOMAIN
    static_assert(false, "Compile-time define missing: BUILD_PROJECT_ORGANIZATION_DOMAIN")
#endif
    app.setOrganizationDomain(BUILD_PROJECT_ORGANIZATION_DOMAIN);
#if !defined BUILD_PROJECT_APPLICATION_NAME
    static_assert(false, "Compile-time define missing: BUILD_PROJECT_APPLICATION_NAME")
#endif
    app.setApplicationName(BUILD_PROJECT_APPLICATION_NAME);
}

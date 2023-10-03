#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "cachecleaner.h"
#include "directorieswatcher.h"
#include "figmalinks.h"
#include "pagesmodel.h"
#include "sectionsdecoratormodel.h"

struct PagesModelInitialized : public PagesModel {
    explicit PagesModelInitialized(QObject *parent = nullptr)
        : PagesModel(QML_IMPORT_ROOT + QStringLiteral("/pages"), parent) {}
};

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName(QStringLiteral("Status"));
    QGuiApplication::setOrganizationDomain(QStringLiteral("status.im"));
    QGuiApplication::setApplicationName(QStringLiteral("Status Desktop Storybook"));

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));

    QQmlApplicationEngine engine;

    const QStringList additionalImportPaths {
        STATUSQ_MODULE_IMPORT_PATH,
        QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
        QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
        QML_IMPORT_ROOT + QStringLiteral("/src"),
        QML_IMPORT_ROOT + QStringLiteral("/pages"),
        QML_IMPORT_ROOT + QStringLiteral("/stubs")
    };

    for (const auto& path : additionalImportPaths)
        engine.addImportPath(path);

    engine.rootContext()->setContextProperty(
                "pagesFolder", QML_IMPORT_ROOT + QStringLiteral("/pages"));

    qmlRegisterType<PagesModelInitialized>("Storybook", 1, 0, "PagesModel");
    qmlRegisterType<SectionsDecoratorModel>("Storybook", 1, 0, "SectionsDecoratorModel");
    qmlRegisterUncreatableType<FigmaLinks>("Storybook", 1, 0, "FigmaLinks", {});

    auto watcherFactory = [additionalImportPaths](QQmlEngine*, QJSEngine*) {
        auto watcher = new DirectoriesWatcher();
        watcher->addPaths(additionalImportPaths);
        return watcher;
    };

    qmlRegisterSingletonType<DirectoriesWatcher>(
                "Storybook", 1, 0, "SourceWatcher", watcherFactory);

    auto cleanerFactory = [](QQmlEngine* engine, QJSEngine*) {
        return new CacheCleaner(engine);
    };

    qmlRegisterSingletonType<CacheCleaner>(
                "Storybook", 1, 0, "CacheCleaner", cleanerFactory);

#ifdef Q_OS_WIN
    const QUrl url(QUrl::fromLocalFile(QML_IMPORT_ROOT + QStringLiteral("/main.qml")));
#else
    const QUrl url(QML_IMPORT_ROOT + QStringLiteral("/main.qml"));
#endif
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return QGuiApplication::exec();
}

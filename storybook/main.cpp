#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>

#include <cachecleaner.h>
#include <directorieswatcher.h>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName("Status");
    QGuiApplication::setOrganizationDomain("status.im");
    QGuiApplication::setApplicationName("Status Desktop Storybook");

    QQmlApplicationEngine engine;

    QStringList additionalImportPaths {
        SRC_DIR + QStringLiteral("/../ui/StatusQ/src"),
        SRC_DIR + QStringLiteral("/../ui/app"),
        SRC_DIR + QStringLiteral("/../ui/imports"),
        SRC_DIR + QStringLiteral("/src"),
        SRC_DIR + QStringLiteral("/pages"),
        SRC_DIR + QStringLiteral("/stubs"),
        SRC_DIR + QStringLiteral("/mocks"),
    };

    for (auto& path : additionalImportPaths)
        engine.addImportPath(path);

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

    const QUrl url(SRC_DIR + QStringLiteral("/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return QGuiApplication::exec();
}

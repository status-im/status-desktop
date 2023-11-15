#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDirIterator>

#include <QtWebView>


#include "cachecleaner.h"
#include "directorieswatcher.h"
#include "figmalinks.h"
#include "pagesmodel.h"
#include "sectionsdecoratormodel.h"
#include "testsrunner.h"
#include "systemutils.h"

#include <memory>

struct PagesModelInitialized : public PagesModel {
    explicit PagesModelInitialized(QObject *parent = nullptr)
        : PagesModel(QML_IMPORT_ROOT + QStringLiteral("/pages"), parent) {}
};

void loadContextPropertiesMocks(const char* storybookRoot, QQmlApplicationEngine& engine);

int main(int argc, char *argv[])
{
    // Required by the WalletConnectSDK view
    QtWebView::initialize();

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

        // Test path added here as a temporary solution. Ideally, tests should
        // be observed separately.
        watcher->addPaths({ QML_IMPORT_ROOT + QStringLiteral("/qmlTests/tests") });
        return watcher;
    };

    qmlRegisterSingletonType<DirectoriesWatcher>(
                "Storybook", 1, 0, "SourceWatcher", watcherFactory);

    auto cleanerFactory = [](QQmlEngine* engine, QJSEngine*) {
        return new CacheCleaner(engine);
    };

    qmlRegisterSingletonType<CacheCleaner>(
                "Storybook", 1, 0, "CacheCleaner", cleanerFactory);

    auto runnerFactory = [](QQmlEngine* engine, QJSEngine*) {
        return new TestsRunner(
                    QCoreApplication::applicationDirPath() + QStringLiteral("/QmlTests"),
                    QML_IMPORT_ROOT + QStringLiteral("/qmlTests/tests"));

    };

    qmlRegisterSingletonType<TestsRunner>(
                "Storybook", 1, 0, "TestsRunner", runnerFactory);

    qmlRegisterSingletonType<SystemUtils>(
                "Storybook", 1, 0, "SystemUtils", [](QQmlEngine*, QJSEngine*) {
                    return new SystemUtils;
                });

    loadContextPropertiesMocks(QML_IMPORT_ROOT, engine);
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

void loadContextPropertiesMocks(const char* storybookRoot, QQmlApplicationEngine& engine) {
    QDirIterator it(QML_IMPORT_ROOT + QStringLiteral("/stubs/nim/sectionmocks"), QDirIterator::Subdirectories);

    while (it.hasNext()) {
        it.next();
        if (it.fileInfo().isFile() && it.fileInfo().suffix() == QStringLiteral("qml")) {
            auto component = std::make_unique<QQmlComponent>(&engine, QUrl::fromLocalFile(it.filePath()));
            if (component->status() != QQmlComponent::Ready) {
                qWarning() << "Failed to load mock for" << it.filePath() << component->errorString();
                continue;
            }

            auto objPtr = std::unique_ptr<QObject>(component->create());
            if(!objPtr) {
                qWarning() << "Failed to create mock for" << it.filePath();
                continue;
            }

            if(!objPtr->property("contextPropertyName").isValid()) {
                qInfo() << "Not a mock, missing property name \"contextPropertyName\"";
                continue;
            }

            auto contextPropertyName = objPtr->property("contextPropertyName").toString();
            auto obj = objPtr.release();
            obj->setParent(&engine);
            engine.rootContext()->setContextProperty(contextPropertyName, obj);
        }
    }
}
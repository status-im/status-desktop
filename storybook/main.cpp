#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QQuickStyle>
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

#include <StatusQ/typesregistration.h>

struct PagesModelInitialized : public PagesModel {
    explicit PagesModelInitialized(QObject *parent = nullptr)
        : PagesModel(QML_IMPORT_ROOT + QStringLiteral("/pages"), parent) {}
};

// Starting from Qt 6.8.3 it's necessary to add prefix when loading qml files
// in order to make the hot reloading working as expected (https://bugreports.qt.io/browse/QTBUG-135448).
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QQmlAbstractUrlInterceptor>

class HotReloadUrlInterceptor : public QQmlAbstractUrlInterceptor {
    unsigned int counter = 0;

    QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) override {
        if (type != QQmlAbstractUrlInterceptor::QmlFile)
            return url;

        return url.toString() + "#"+ QString::number(counter++);
    }
};
#endif

void loadContextPropertiesMocks(const char* storybookRoot, QQmlApplicationEngine& engine);

int main(int argc, char *argv[])
{
    bool hasExplicitStyleSet = false;
    for (size_t i = 1; i < argc; i++)
    {
        if (qstrcmp(argv[i], "-style") == 0) { // Qt eats these standard/builtin args as soon as it sees them; so process before creating qApp instance
            hasExplicitStyleSet = true;
            break;
        }
    }

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
    QGuiApplication::setApplicationDisplayName(QStringLiteral("%1 [Qt %2]").arg(QGuiApplication::applicationName(), qVersion()));

    if (!hasExplicitStyleSet)
        QQuickStyle::setStyle(QStringLiteral("Universal")); // only used as a basic style for SB itself

    QCommandLineParser cmdParser;
    cmdParser.addHelpOption();
    cmdParser.addPositionalArgument(QStringLiteral("page"), QStringLiteral("Open the given page on startup"));
    cmdParser.process(app.arguments());

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));
    auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if(!chromiumFlags.contains("--disable-seccomp-filter-sandbox")) {
        chromiumFlags +=" --disable-seccomp-filter-sandbox";
    }
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags);

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    HotReloadUrlInterceptor interceptor;
#endif

    QQmlApplicationEngine engine;

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    engine.addUrlInterceptor(&interceptor);
#endif

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

    engine.rootContext()->setContextProperty(QStringLiteral("pagesFolder"),
                                             QML_IMPORT_ROOT + QStringLiteral("/pages"));

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

    registerStatusQTypes();

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

    const auto args = cmdParser.positionalArguments();
    if (!args.isEmpty())
        engine.setInitialProperties({{QStringLiteral("currentPage"), args.constFirst()}});

    engine.load(url);

    qInfo() << "Storybook started, Qt runtime version:" << qVersion() << "; built against version:" << QLibraryInfo::version().toString() <<
        "installed in:"
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
            << QLibraryInfo::path(QLibraryInfo::PrefixPath)
#else
            << QLibraryInfo::location(QLibraryInfo::PrefixPath)
#endif
            << "; QQC style:" << QQuickStyle::name();

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

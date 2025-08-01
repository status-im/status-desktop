#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include <Storybook/storybooksetup.h>
#include <Storybook/qmlfilesserver.h>

#include <memory>

#include <StatusQ/typesregistration.h>

void loadContextPropertiesMocks(const char* storybookRoot, QQmlApplicationEngine& engine);

int main(int argc, char *argv[])
{
    bool hasExplicitStyleSet = false;
    for (size_t i = 1; i < argc; i++)
    {
        // Qt uses these standard/builtin args as soon as it sees them; so process before creating qApp instance
        if (qstrcmp(argv[i], "-style") == 0) {
            hasExplicitStyleSet = true;
            break;
        }
    }

    // Required by the WalletConnectSDK view
    QtWebView::initialize();

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

#ifdef ANDROID
    static constexpr auto defaultMode = "remote";
#else
    static constexpr auto defaultMode = "local";
#endif

    QCommandLineOption modeOption(QStringList() << QStringLiteral("m") << QStringLiteral("mode"),
                                  QStringLiteral("mode (local or remote)"),
                                  QStringLiteral("mode"), defaultMode);

    cmdParser.addOption(modeOption);
    cmdParser.process(app.arguments());

    const QString mode = cmdParser.value(modeOption);

    if (mode != QStringLiteral("local") && mode != QStringLiteral("remote")) {
        qWarning() << "Invalid mode, use 'local' or 'remote'";
        return 0;
    }

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));
    auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if(!chromiumFlags.contains("--disable-seccomp-filter-sandbox")) {
        chromiumFlags +=" --disable-seccomp-filter-sandbox";
    }
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags);

    QStringList additionalImportPaths;
    additionalImportPaths << QStringLiteral("qrc:/");

    if (mode == QStringLiteral("local")) {
        additionalImportPaths << QStringList {
            STATUSQ_MODULE_IMPORT_PATH,
            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
            QML_IMPORT_ROOT + QStringLiteral("/src"),
            QML_IMPORT_ROOT + QStringLiteral("/pages"),
            QML_IMPORT_ROOT + QStringLiteral("/stubs"),
        };

        StorybookSetup::registerTypesLocal(
            additionalImportPaths,
            QML_IMPORT_ROOT + QStringLiteral("/pages"),
            QCoreApplication::applicationDirPath() + QStringLiteral("/QmlTests"),
            QML_IMPORT_ROOT + QStringLiteral("/qmlTests/tests"));
    } else {
        additionalImportPaths << QStringLiteral("http://localhost:8080/0");

        StorybookSetup::registerTypesRemote(QUrl("http://localhost:8080/version"),
                                            QUrl("http://localhost:8080/pages"),
                                            QUrl("http://localhost:8080"));
    }

    QQmlApplicationEngine engine;

    for (const auto& path : additionalImportPaths)
        engine.addImportPath(path);

    StorybookSetup::configureEngine(&engine, mode == QStringLiteral("local"));
    registerStatusQTypes();

    loadContextPropertiesMocks(QML_IMPORT_ROOT, engine);

    const QUrl url("qrc:/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [url](const QUrl &objUrl) {
        if (url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    const auto args = cmdParser.positionalArguments();
    if (!args.isEmpty())
        engine.setInitialProperties({{QStringLiteral("currentPage"), args.constFirst()}});

    if (mode == QStringLiteral("remote")) {
        auto server = new QmlFilesServer({
            STATUSQ_MODULE_IMPORT_PATH,
            // stubs first to give precedence over real stores
            QML_IMPORT_ROOT + QStringLiteral("/stubs"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
            QML_IMPORT_ROOT + QStringLiteral("/src"),
            QML_IMPORT_ROOT + QStringLiteral("/pages"),
        }, QML_IMPORT_ROOT + QStringLiteral("/pages"), true, &engine);

        server->start(8080);
    }

    engine.load(url);

    qInfo() << "Storybook started, Qt runtime version:" << qVersion() << "; built against version:" << QLibraryInfo::version().toString() <<
        "installed in:" << QLibraryInfo::path(QLibraryInfo::PrefixPath)
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

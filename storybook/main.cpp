#include <QDirIterator>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include <Storybook/storybooksetup.h>

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
    cmdParser.process(app.arguments());

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));
    auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if(!chromiumFlags.contains("--disable-seccomp-filter-sandbox")) {
        chromiumFlags +=" --disable-seccomp-filter-sandbox";
    }
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags);

    const QStringList additionalImportPaths {
        QStringLiteral("qrc:/"),
        STATUSQ_MODULE_IMPORT_PATH,
        QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
        QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
        QML_IMPORT_ROOT + QStringLiteral("/src"),
        QML_IMPORT_ROOT + QStringLiteral("/pages"),
        QML_IMPORT_ROOT + QStringLiteral("/stubs")
    };

    StorybookSetup::registerTypes(additionalImportPaths,
                                  QML_IMPORT_ROOT + QStringLiteral("/pages"),
                                  QCoreApplication::applicationDirPath() + QStringLiteral("/QmlTests"),
                                  QML_IMPORT_ROOT + QStringLiteral("/qmlTests/tests"));


    QQmlApplicationEngine engine;

    for (const auto& path : additionalImportPaths)
        engine.addImportPath(path);

    StorybookSetup::configureEngine(&engine, QML_IMPORT_ROOT + QStringLiteral("/pages"));
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

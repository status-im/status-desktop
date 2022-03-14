#include "AppController.h"

#include "DI.h"
#include "../Core/Engine.h"
#include "../Core/StatusSyntaxHighlighter.h"
#include "../Core/SingleInstance.h"
#include "../Common/Utils.h"
#include "../Global/LocalAppSettings.h"
#include "../Global/LocalAccountSettings.h"

#include "AppWindow.h"
#include "../Modules/ModuleBuilder.h"

#include <QtGui>
#include <QtQml>
//#include <QtCore> <- include for QTranslator

using namespace Status;

AppController::AppController()
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication::setOrganizationName("Status");
    QGuiApplication::setOrganizationDomain("status.im");
    QGuiApplication::setApplicationName("Status Desktop");

    Status::Logger::init();
    Utils::ensureDirectories();
}

void registerTypes()
{
    //  Once we fully move to c++ we should include the following line instead the line below it (it's here just to align with the current qml files).
    //  qmlRegisterType<AppWindow>("AppWindow", 0 , 1, "AppWindow");
    qmlRegisterType<AppWindow>("DotherSide", 0 , 1, "StatusWindow");
    qmlRegisterType<StatusSyntaxHighlighterHelper>("DotherSide", 0, 1, "StatusSyntaxHighlighter");
}

void registerResources()
{
    Engine::instance()->addImportPath("qrc:/./StatusQ/src");
    Engine::instance()->addImportPath("qrc:/./imports");
    Engine::instance()->addImportPath("qrc:/./app");

    // This will be removed once we completely move to c++, it's here to align with the current qml code.
    Engine::instance()->rootContext()->setContextProperty("cppApp", true);
    Engine::instance()->rootContext()->setContextProperty("production", STATUS_DEVELOPMENT);

    Engine::instance()->rootContext()->setContextProperty("localAppSettings", &LocalAppSettings::instance());
    Engine::instance()->rootContext()->setContextProperty("localAccountSettings", &LocalAccountSettings::instance());

    QString statusSourceDir(STATUS_SOURCE_DIR);
    QResource::registerResource(statusSourceDir + "/../resources.rcc");
}

int AppController::exec(int& argc, char** argv)
{
    int code;

    registerTypes();

    try
    {
        QGuiApplication app(argc, argv);

        // This is here just to check loading translation on the cmake side,
        // will be handled much better later.
        //
        //    QTranslator translator;
        //    const QString baseName = "app_es_ES";
        //    if (translator.load(baseName, QLatin1String(":/i18n"))){
        //        app.installTranslator(&translator);
        //    }

        auto md5DataDir = QString(QCryptographicHash::hash(Utils::defaultDataDir().toLatin1(), QCryptographicHash::Md5).toHex());
        auto openUri = ""; // CLI uri should be used here ("status-im:// URI to open a chat or other")
        auto singleInstance = std::make_unique<SingleInstance>(md5DataDir, openUri);

        if (!singleInstance->isFirstInstance())
        {
            auto err = "Terminating the app as the second instance";
            throw std::runtime_error(err);
        }

        auto rootModule = Injector.create<Modules::ModuleBuilder>()();
        rootModule->load();

        registerResources();

        AppWindow* appWindow = nullptr;
        QString qmlFile = QStringLiteral("qrc:/main.qml");

        auto handleAppWinCreation = [url = qmlFile, &appWindow, &singleInstance](QObject* obj, const QUrl& objUrl) {
            if(url == objUrl.toString())
            {
                if(obj)
                {
                    AppWindow* appWindow = qobject_cast<AppWindow*>(obj);
                    QObject::connect(singleInstance.get(), &SingleInstance::secondInstanceDetected, [appWindow](){
                        appWindow->makeTheAppActive();
                    });

                    QObject::connect(singleInstance.get(), &SingleInstance::eventReceived, [](const QString& eventStr){
                        qInfo() << "Received event: " << eventStr;
                        // We need to handle it here.
                    });
                }
                else
                {
                    auto err = "Failed to create: " + url;
                    throw std::runtime_error(err.toStdString());
                }
            }
        };

        Engine::create(qmlFile);
        QObject::connect(Engine::instance(), &Engine::objectCreated, &app, handleAppWinCreation);

        code = app.exec();
    }
    catch (std::exception& e)
    {
        fprintf(stderr, "error: %s\n", e.what());
        code = -1;
    }
    catch (...)
    {
        fprintf(stderr, "unknown error\n");
        code = -1;
    }

    return code;
}

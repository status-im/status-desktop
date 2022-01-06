#include "DOtherSide.h"
#include "app_controller.h"
#include "constants.h"
#include "libstatus.h"
#include "logs.h"
#include "signals.h"
#include "singleton.h"
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMessageBox>
#include <QQmlApplicationEngine>
#include <QResource>
#include <QScopedPointer>
#include <iostream>

int main(int argc, char* argv[])
{
	qInstallMessageHandler(logFormatter);

	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
#endif

	QGuiApplication app(argc, argv);
	app.setOrganizationName("Status");
	app.setOrganizationDomain("status.im");
	app.setApplicationName("Status Desktop");

	if(!Constants::ensureDirectories()) return 1;

	// Init keystore
	const char* initKeystoreResult = InitKeystore(Constants::applicationPath(Constants::Keystore).toUtf8().data());
	QJsonObject initKeystoreJson = QJsonDocument::fromJson(initKeystoreResult).object();
	if(initKeystoreJson["error"].toString() != "")
	{
		QMessageBox msgBox;
		msgBox.setIcon(QMessageBox::Critical);
		msgBox.setText("Could not open keystore: " + initKeystoreJson["error"].toString());
		msgBox.exec();
		return 1;
	}

	QScopedPointer<Signals::Manager> signalManager(Signals::Manager::instance());

	// Registering metatypes
	qRegisterMetaType<Signals::Signal>("Signal");
	qRegisterMetaType<Signals::NodeSignal>("NodeSignal");


	qInfo("starting application controller...");
	AppController appController = AppController();
	appController.start();

	QResource::registerResource("../resources.rcc");

	DOtherSide::registerMetaTypes();

	Global::Singleton::instance()->engine()->addImportPath("qrc:/./StatusQ/src");
	Global::Singleton::instance()->engine()->addImportPath("qrc:/./imports");

	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(
		Global::Singleton::instance()->engine(),
		&QQmlApplicationEngine::objectCreated,
		&app,
		[url](QObject* obj, const QUrl& objUrl) {
			if(!obj && url == objUrl) QCoreApplication::exit(-1);
		},
		Qt::QueuedConnection);

	Global::Singleton::instance()->engine()->load(url);

	qInfo("starting application...");
	return app.exec();
}

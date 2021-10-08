#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QJsonDocument>
#include <QJsonObject>
#include <iostream>

extern "C"
{
#include "libstatus.h"
}

int main(int argc, char *argv[])
{

    QString hello = "Hello World!";
    const char* result = HashMessage(hello.toUtf8().data()); // <- HashMessage comes from libstatus.h
    const auto response = QJsonDocument::fromJson(QString(result).toUtf8()).object(); // <- For now, status-go always returns json
	if (!response["error"].isUndefined() || !response["error"].toString().isEmpty()){ // <- Always do error handling
        std::cout << "Could not obtain hash: " << response["result"].toString().toStdString() << std::endl << std::flush;
    } else {
        std::cout << "Hash of HelloWorld: " << response["result"].toString().toStdString() << std::endl << std::flush;
    }

    // For handling signals, see:
    // https://github.com/richard-ramos/status-cpp/blob/master/src/core/status.cpp#L36
    // https://github.com/richard-ramos/status-cpp/blob/master/src/core/status.cpp#L124-L127


#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl)
        {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

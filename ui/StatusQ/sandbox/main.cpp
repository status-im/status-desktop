#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "sandboxapp.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    SandboxApp app(argc, argv);
    app.startEngine();

    return app.exec();
}

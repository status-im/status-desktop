#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "sandboxapp.h"

int main(int argc, char *argv[])
{
    SandboxApp app(argc, argv);

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));

    app.setOrganizationName("Status");
    app.setOrganizationDomain("status.im");
    app.setApplicationName("Sandbox");

    app.startEngine();

    return app.exec();
}

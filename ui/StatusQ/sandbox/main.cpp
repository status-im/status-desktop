#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "sandboxapp.h"

#include <qqmlsortfilterproxymodeltypes.h>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    SandboxApp app(argc, argv);

    qqsfpm::registerTypes();

    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));

    app.setOrganizationName("Status");
    app.setOrganizationDomain("status.im");
    app.setApplicationName("Sandbox");

    app.startEngine();

    return app.exec();
}

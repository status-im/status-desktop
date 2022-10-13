#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName("Status");
    QGuiApplication::setOrganizationDomain("status.im");
    QGuiApplication::setApplicationName("Status Desktop Storybook");

    QQmlApplicationEngine engine;

    engine.addImportPath(QStringLiteral(":/"));
    engine.addImportPath(SRC_DIR + QStringLiteral("/../ui/StatusQ/src"));
    engine.addImportPath(SRC_DIR + QStringLiteral("/../ui/app"));
    engine.addImportPath(SRC_DIR + QStringLiteral("/../ui/imports"));
    engine.addImportPath(SRC_DIR + QStringLiteral("/stubs"));

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return QGuiApplication::exec();
}

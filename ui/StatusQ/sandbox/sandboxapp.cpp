#include "sandboxapp.h"

#include <QQmlContext>
#include <QWindow>
#include <QDebug>

SandboxApp::SandboxApp(int &argc, char **argv)
    : QGuiApplication(argc, argv),
      m_handler(new Handler(this))
{
    connect(m_handler, &Handler::restartQml, this, &SandboxApp::restartEngine, Qt::QueuedConnection);
}

void SandboxApp::startEngine()
{
    const QUrl url(applicationDirPath() + "/../main.qml");

    m_engine.rootContext()->setContextProperty("app", m_handler);

    m_engine.addImportPath(applicationDirPath() + "/../../src");
    qDebug() << m_engine.importPathList();
    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
        this, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    m_engine.load(url);

    QWindow *rootWindow = qobject_cast<QWindow*>(m_engine.rootObjects().at(0));
    if (rootWindow) {
        removeTitleBar(rootWindow->winId());
    } else {
        qDebug() << "Window doesn't exist";
    }
}

void SandboxApp::restartEngine()
{
    const QUrl url(applicationDirPath() + "/../main.qml");
    QWindow *rootWindow = qobject_cast<QWindow*>(m_engine.rootObjects().at(0));
    if (rootWindow) {

        rootWindow->close();
    }
    m_engine.clearComponentCache();
    m_engine.load(url);
}

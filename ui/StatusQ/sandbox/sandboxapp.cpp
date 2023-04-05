#include "sandboxapp.h"

#include <QQmlContext>
#include <QWindow>
#include <QDebug>
#include <QDirIterator>

SandboxApp::SandboxApp(int &argc, char **argv)
    : QGuiApplication(argc, argv)
{
#ifdef QT_DEBUG
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, [this](const QString&) {
        restartEngine();
    });
#endif
}

void SandboxApp::startEngine()
{
#ifdef QT_DEBUG
    m_watcher.addPath(applicationDirPath() + "/../");
    QDirIterator it(applicationDirPath() + "/../", QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        if (!it.filePath().isEmpty()) {
            m_watcher.addPath(it.filePath());
        }
        it.next();
    }
#endif

    m_engine.addImportPath(STATUSQ_MODULE_IMPORT_PATH);
    qDebug() << m_engine.importPathList();

    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
        this, [this](QObject *obj, const QUrl &objUrl) {
            if (!obj && m_url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    m_engine.load(m_url);
}

void SandboxApp::restartEngine()
{
    QWindow *rootWindow = qobject_cast<QWindow*>(m_engine.rootObjects().at(0));
    if (rootWindow) {
        rootWindow->close();
        rootWindow->deleteLater();
    }
    m_engine.clearComponentCache();
    m_engine.load(m_url);
}

#include "sandboxapp.h"

#include <QQmlContext>
#include <QWindow>
#include <QDebug>
#include <QDirIterator>

#include "statuswindow.h"
#include "spellchecker.h"

SandboxApp::SandboxApp(int &argc, char **argv)
    : QGuiApplication(argc, argv)
{
#ifdef QT_DEBUG
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, [this](const QString&) {
        restartEngine();
    });

#endif
}

void SandboxApp::startEngine()
{
    qmlRegisterType<StatusWindow>("Sandbox", 0, 1, "StatusWindow");
    qmlRegisterType<SpellChecker>("Sandbox", 0, 1, "Spellchecker");

#ifdef QT_DEBUG
    const QUrl url = QUrl::fromLocalFile(SRC_DIR + QStringLiteral("/main.qml"));
    m_watcher.addPath(applicationDirPath() + "/../");
    QDirIterator it(applicationDirPath() + "/../", QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        if (!it.filePath().isEmpty()) {
            m_watcher.addPath(it.filePath());
        }
        it.next();
    }
#else
    const QUrl url(QStringLiteral("qrc:/main.qml"));
#endif

#ifdef QT_DEBUG
    m_engine.addImportPath(SRC_DIR + QStringLiteral("/../src"));
#else
    m_engine.addImportPath(QStringLiteral(":/"));
#endif
    qDebug() << m_engine.importPathList();
    QObject::connect(&m_engine, &QQmlApplicationEngine::objectCreated,
        this, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    m_engine.load(url);
}

void SandboxApp::restartEngine()
{
    const QUrl url = QUrl::fromLocalFile(SRC_DIR + QStringLiteral("/main.qml"));
    QWindow *rootWindow = qobject_cast<QWindow*>(m_engine.rootObjects().at(0));
    if (rootWindow) {
        rootWindow->close();
        rootWindow->deleteLater();
    }
    m_engine.clearComponentCache();
    m_engine.load(url);
}

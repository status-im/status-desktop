#include "sandboxapp.h"

#include <QQmlContext>
#include <QWindow>
#include <QDebug>
#include <QDirIterator>

SandboxApp::SandboxApp(int &argc, char **argv)
    : QGuiApplication(argc, argv)
{
#ifdef QT_DEBUG
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this](const QString& path) {
        qDebug().noquote() << QString("File change detected in '%1'").arg(path);
        restartEngine();
    });
#endif
}
#ifdef QT_DEBUG
void SandboxApp::watchDirectoryChanges(const QString& path)
{
    qDebug() << "Iterating to watch over:" << path;

    const auto dirFilters = QDir::Files | QDir::NoDotAndDotDot;
    const auto fileNameFilters = QStringList { "*.qml" };

    for (QDirIterator it(path, fileNameFilters, dirFilters, QDirIterator::Subdirectories); it.hasNext(); it.next()) {
        if (!it.filePath().isEmpty()) {
            m_watcher.addPath(it.filePath());
        }
    }
}
#endif
void SandboxApp::startEngine()
{
#ifdef QT_DEBUG
    watchDirectoryChanges(SANDBOX_SRC_DIR);
    watchDirectoryChanges(STATUSQ_MODULE_PATH);
#endif
    restartEngine();
}

void SandboxApp::restartEngine()
{
    const bool firstRun { !m_engine };

    if (!firstRun)
        qDebug() << "Restarting QML engine";

    m_engine = std::make_unique<QQmlApplicationEngine>();
    m_engine->addImportPath(STATUSQ_MODULE_IMPORT_PATH);

    if (firstRun)
        qDebug() << "QQmlEngine import paths: " << m_engine->importPathList();

    QObject::connect(m_engine.get(), &QQmlApplicationEngine::objectCreated,
        this, [this](QObject *obj, const QUrl &objUrl) {
            if (!obj && m_url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    m_engine->load(m_url);
}

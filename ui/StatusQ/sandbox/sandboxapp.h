#ifndef SANDBOXAPP_H
#define SANDBOXAPP_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#ifdef QT_DEBUG
#include <QFileSystemWatcher>
#endif

class SandboxApp : public QGuiApplication
{
public:
    SandboxApp(int &argc, char **argv);

    void startEngine();

public slots:
    void restartEngine();

private:
    std::unique_ptr<QQmlApplicationEngine> m_engine;

#ifdef QT_DEBUG
    QFileSystemWatcher m_watcher;
    void watchDirectoryChanges(const QString& path);
#endif

    const QUrl m_url {
#ifdef QT_DEBUG
        QUrl::fromLocalFile(SANDBOX_SRC_DIR + QStringLiteral("/main.qml"))
#else
        QStringLiteral("qrc:/main.qml")
#endif
    };
};

#endif // SANDBOXAPP_H

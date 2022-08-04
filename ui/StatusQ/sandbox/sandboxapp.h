#ifndef SANDBOXAPP_H
#define SANDBOXAPP_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#ifdef QT_DEBUG
#include <QFileSystemWatcher>
#endif

#include "handler.h"

class SandboxApp : public QGuiApplication
{
public:
    SandboxApp(int &argc, char **argv);

    void startEngine();

public slots:
    void restartEngine();

private:
    QQmlApplicationEngine m_engine;
    Handler *m_handler;

#ifdef QT_DEBUG
    QFileSystemWatcher m_watcher;
#endif
};

#endif // SANDBOXAPP_H

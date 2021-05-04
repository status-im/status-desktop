#ifndef SANDBOXAPP_H
#define SANDBOXAPP_H

#include <QGuiApplication>
#include <QQmlApplicationEngine>

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
};

#endif // SANDBOXAPP_H

#pragma once

#include <QQmlApplicationEngine>

namespace Global
{

class Singleton
{
public:
    QQmlApplicationEngine* engine();
    static Singleton* instance();

private:
    static Singleton* theInstance;
    explicit Singleton();
    QQmlApplicationEngine* m_engine;
};

} // namespace Global

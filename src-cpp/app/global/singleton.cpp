#include "singleton.h"
#include <QQmlApplicationEngine>

namespace Global
{
Singleton* Singleton::instance()
{
    static auto singleton = new Singleton();
    return singleton;
}

QQmlApplicationEngine* Singleton::engine()
{
    return &m_engine;
}
} // namespace Global

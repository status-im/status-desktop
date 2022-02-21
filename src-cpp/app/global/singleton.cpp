#include "singleton.h"
#include <QQmlApplicationEngine>

namespace Global
{
Singleton* Singleton::theInstance;

Singleton* Singleton::instance()
{
    if(theInstance == 0) theInstance = new Singleton();
    return theInstance;
}

Singleton::Singleton()
{
    m_engine = new QQmlApplicationEngine();
}

QQmlApplicationEngine* Singleton::engine()
{
    return m_engine;
}
} // namespace Global

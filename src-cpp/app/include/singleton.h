#pragma once

#include <QQmlApplicationEngine>

namespace Global
{

class Singleton
{
public:
    // FIXME: should return reference
    QQmlApplicationEngine* engine();
    // FIXME: should return reference
    static Singleton* instance();

private:
    Singleton() = default;
    QQmlApplicationEngine m_engine;
};

} // namespace Global

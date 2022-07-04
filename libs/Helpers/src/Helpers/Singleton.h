#pragma once

#include <memory>

namespace Status::Helpers
{

template<typename T>
class Singleton
{
public:
    virtual ~Singleton<T>() = default;

    static T& getInstance()
    {
        static T instance;
        return instance;
    }

    Singleton<T>(const Singleton<T>&) = delete;
    Singleton<T>& operator = (const Singleton<T>&) = delete;
private:

    Singleton<T>() = default;
};

}

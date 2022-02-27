#pragma once

#include <QtCore>

template<class T>
[[nodiscard]] T extractValue(const QVariant& value)
{
    if constexpr (std::is_same_v<bool, T>)
            return value.toBool();
    else if constexpr (std::is_same_v<QString, T>)
            return value.toString();
    else if constexpr (std::is_same_v<int, T>)
            return value.toInt();
    else if constexpr (std::is_same_v<float, T>)
            return value.toFloat();
    return T();
}

#define REGISTER_RW_PROPERTY(class, nspace, key, type)                                  \
    Q_SIGNALS:                                                                          \
        void key##Changed();                                                            \
    public:                                                                             \
    Q_PROPERTY(type key READ get_##key WRITE set_##key NOTIFY key##Changed)             \
    [[nodiscard]] type get_##key() const                                                \
    {                                                                                   \
        if(!class::instance().settings ||                                               \
            class::instance().settings->fileName().isEmpty())                           \
        {                                                                               \
            qFatal("Please set settings file name first");                              \
            return type();                                                              \
        }                                                                               \
        auto def = nspace::getDefaultValue(nspace::key);                                \
        return extractValue<type>(class::instance().settings->value(nspace::key, def)); \
    }                                                                                   \
    void set_##key(const type& value)                                                   \
    {                                                                                   \
        if(!class::instance().settings ||                                               \
            class::instance().settings->fileName().isEmpty())                           \
        {                                                                               \
            qFatal("Please set settings file name first");                              \
            return;                                                                     \
        }                                                                               \
        class::instance().settings->setValue(nspace::key, value);                       \
        emit key##Changed();                                                            \
    }

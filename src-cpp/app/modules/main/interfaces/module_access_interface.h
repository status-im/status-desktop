#pragma once

#include <QObject>

namespace Modules::Main
{
class IModuleAccess
{
public:
    virtual void load() = 0;
    virtual bool isLoaded() = 0;

    virtual ~IModuleAccess() = default;

    // FIXME: signals shouldn't be used in a class that is not QObject
signals:
    virtual void loaded() = 0;
};
} // namespace Modules::Main

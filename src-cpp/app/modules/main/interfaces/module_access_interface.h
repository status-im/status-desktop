#ifndef IMODULEACCESS_H
#define IMODULEACCESS_H

#include <QObject>

namespace Modules::Main
{
class IModuleAccess
{
public:
    virtual void load() = 0;
    virtual bool isLoaded() = 0;
signals:
    virtual void loaded() = 0;
};
} // namespace Modules::Main

Q_DECLARE_INTERFACE(Modules::Main::IModuleAccess, "Modules::Main::IModuleAccess");

#endif // IMODULEACCESS_H

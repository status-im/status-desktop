#ifndef IWALLETMODULEACCESS_H
#define IWALLETMODULEACCESS_H

#include "../../interfaces/module_access_interface.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
class IWalletModuleAccess: virtual public IModuleAccess
{
};
}; // namespace Wallet
}; // namespace Main
}; // namespace Modules

#endif // IWALLETMODULEACCESS_H

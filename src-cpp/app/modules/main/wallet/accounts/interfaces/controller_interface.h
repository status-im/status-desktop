#ifndef IWALLETACCOUNTSCONTROLLER_H
#define IWALLETACCOUNTSCONTROLLER_H

#include "../../../interfaces/controller_interface.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
//   Abstract class for any input/interaction with this module.

class IAccountsController: public IController
{
public:
    virtual void init() = 0;
};
} // namespave Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // IWALLETACCOUNTSCONTROLLER_H

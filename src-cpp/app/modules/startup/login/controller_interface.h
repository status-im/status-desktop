#pragma once

#include "accounts/account.h"

namespace Modules
{
namespace Startup
{
namespace Login
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
    virtual void init() = 0;

    virtual QVector<Accounts::AccountDto> getOpenedAccounts() = 0;

    virtual void setSelectedAccountKeyUid(QString keyUid) = 0;

    virtual void login(QString password) = 0;
};
} // namespace Login
} // namespace Startup
} // namespace Modules

#pragma once

#include "accounts/generated_account.h"

namespace Modules
{
namespace Startup
{
namespace Onboarding
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
    virtual void init() = 0;

    virtual QVector<Accounts::GeneratedAccountDto> getGeneratedAccounts() = 0;

    virtual void setSelectedAccountByIndex(int index) = 0;

    virtual void storeSelectedAccountAndLogin(QString password) = 0;

    virtual Accounts::GeneratedAccountDto getImportedAccount() = 0;

    virtual QString validateMnemonic(QString mnemonic) = 0;

    virtual void importMnemonic(QString mnemonic) = 0;
};
} // namespace Onboarding
} // namespace Startup
} // namespace Modules

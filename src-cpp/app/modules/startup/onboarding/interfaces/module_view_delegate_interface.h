#pragma once
#include "accounts/generated_account.h"
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad() = 0;

	virtual void setSelectedAccountByIndex(int index) = 0;

	virtual void storeSelectedAccountAndLogin(QString password) = 0;

	virtual Accounts::GeneratedAccountDto getImportedAccount() = 0;

	virtual QString validateMnemonic(QString mnemonic) = 0;

	virtual void importMnemonic(QString mnemonic) = 0;
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules
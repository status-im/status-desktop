#pragma once
#include "accounts/generated_account.h"
#include <QString>
#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void setSelectedAccountByIndex(int index)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void storeSelectedAccountAndLogin(QString password)
	{
		throw std::domain_error("Not implemented");
	}

	virtual Accounts::GeneratedAccountDto getImportedAccount()
	{
		throw std::domain_error("Not implemented");
	}

	virtual QString validateMnemonic(QString mnemonic)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void importMnemonic(QString mnemonic)
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules
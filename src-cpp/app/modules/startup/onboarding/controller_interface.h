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
	virtual void init()
	{
		throw std::domain_error("Not implemented");
	}
	virtual QVector<Accounts::GeneratedAccountDto> getGeneratedAccounts()
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
} // namespace Onboarding
} // namespace Startup
} // namespace Modules

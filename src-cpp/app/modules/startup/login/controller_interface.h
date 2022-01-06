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
	virtual void init()
	{
		throw std::domain_error("Not implemented");
	}
	virtual QVector<Accounts::AccountDto> getOpenedAccounts()
	{
		throw std::domain_error("Not implemented");
	}
	virtual void setSelectedAccountKeyUid(QString keyUid)
	{
		throw std::domain_error("Not implemented");
	}
	virtual void login(QString password)
	{
		throw std::domain_error("Not implemented");
	}
};
} // namespace Login
} // namespace Startup
} // namespace Modules

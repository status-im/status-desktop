#pragma once
#include "../item.h"
#include <QString>
#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Login
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void setSelectedAccount(Item item)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void login(QString password)
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules
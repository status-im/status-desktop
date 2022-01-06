#pragma once

#include "accounts/service_interface.h"
#include "app_controller_delegate.h"
#include "controller.h"
#include <stdexcept>

namespace Modules
{
namespace Startup
{
class ModuleControllerDelegateInterface
{
public:
	virtual void userLoggedIn()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void emitLogOut()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Startup
}; // namespace Modules
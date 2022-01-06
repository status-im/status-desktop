#pragma once

#include "accounts/service_interface.h"
#include "app_controller_delegate.h"
#include "controller.h"
#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleControllerDelegateInterface
{
public:
	virtual void setupAccountError()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void importAccountError()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void importAccountSuccess()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules
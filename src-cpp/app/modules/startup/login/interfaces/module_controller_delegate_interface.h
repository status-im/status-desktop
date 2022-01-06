#pragma once

#include "accounts/service_interface.h"
#include "app_controller_delegate.h"
#include "controller.h"
#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Login
{
class ModuleControllerDelegateInterface
{
public:
	virtual void emitAccountLoginError(QString error)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void emitObtainingPasswordError(QString errorDescription)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void emitObtainingPasswordSuccess(QString password)
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules
#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleAccessInterface
{
public:
	virtual void load()
	{
		throw std::domain_error("Not implemented");
	}

	virtual bool isLoaded()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules

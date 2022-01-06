#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
namespace Login
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
}; // namespace Login
}; // namespace Startup
}; // namespace Modules

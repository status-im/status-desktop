#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
class ModuleAccessInterface
{
public:
	virtual void load()
	{
		throw std::domain_error("Not implemented");
	}

    virtual void moveToAppState()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Startup
}; // namespace Modules

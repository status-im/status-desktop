#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
class ModuleLoginDelegateInterface
{
public:
	virtual void loginDidLoad()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Startup
}; // namespace Modules
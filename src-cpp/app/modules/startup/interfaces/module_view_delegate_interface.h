#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Startup
}; // namespace Modules
#pragma once

#include <stdexcept>

namespace Modules
{
namespace Startup
{
class ModuleOnboardingDelegateInterface
{
public:
	virtual void onboardingDidLoad()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Startup
}; // namespace Modules
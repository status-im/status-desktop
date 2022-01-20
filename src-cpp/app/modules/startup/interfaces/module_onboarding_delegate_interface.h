#pragma once

namespace Modules
{
namespace Startup
{
class ModuleOnboardingDelegateInterface
{
public:
	virtual void onboardingDidLoad() = 0;
};
}; // namespace Startup
}; // namespace Modules
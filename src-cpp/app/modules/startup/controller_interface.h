#pragma once

namespace Modules
{
namespace Startup
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
	virtual void init()
	{
		throw std::domain_error("Not implemented");
	}
	virtual bool shouldStartWithOnboardingScreen()
	{
		throw std::domain_error("Not implemented");
	}
};
} // namespace Startup
} // namespace Modules
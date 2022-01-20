#pragma once

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleControllerDelegateInterface
{
public:
	virtual void setupAccountError() = 0;

	virtual void importAccountError() = 0;

	virtual void importAccountSuccess() = 0;
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules
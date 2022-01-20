#pragma once

namespace Modules
{
namespace Startup
{
class ModuleControllerDelegateInterface
{
public:
	virtual void userLoggedIn() = 0;

	virtual void emitLogOut() = 0;
};
}; // namespace Startup
}; // namespace Modules
#pragma once

namespace Modules
{
namespace Startup
{
class ModuleLoginDelegateInterface
{
public:
	virtual void loginDidLoad() = 0;
};
}; // namespace Startup
}; // namespace Modules
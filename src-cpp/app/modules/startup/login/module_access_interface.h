#pragma once

namespace Modules
{
namespace Startup
{
namespace Login
{
class ModuleAccessInterface
{
public:
	virtual void load() = 0;

	virtual bool isLoaded() = 0;
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules

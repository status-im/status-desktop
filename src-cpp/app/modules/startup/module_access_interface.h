#pragma once

namespace Modules
{
namespace Startup
{
class ModuleAccessInterface
{
public:
	virtual void load() = 0;

    virtual void moveToAppState() = 0;
};
}; // namespace Startup
}; // namespace Modules

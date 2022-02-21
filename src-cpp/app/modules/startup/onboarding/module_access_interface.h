#pragma once

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class ModuleAccessInterface
{
public:
    virtual void load() = 0;

    virtual bool isLoaded() = 0;
};
}; // namespace Onboarding
}; // namespace Startup
}; // namespace Modules

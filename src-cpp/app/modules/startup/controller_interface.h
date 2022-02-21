#pragma once

namespace Modules
{
namespace Startup
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
    virtual void init() = 0;

    virtual bool shouldStartWithOnboardingScreen() = 0;
};
} // namespace Startup
} // namespace Modules

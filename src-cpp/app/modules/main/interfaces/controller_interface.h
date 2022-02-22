#pragma once

namespace Modules::Main
{
//   Abstract class for any input/interaction with this module.
class IController
{
public:
    virtual void init() = 0;
    virtual ~IController() = default;
};
} // namespace Modules::Main

#pragma once

namespace Modules
{
namespace Main
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
	virtual void init() = 0;
};
} // namespace Main
} // namespace Modules
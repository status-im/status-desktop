#pragma once

#include <stdexcept>

namespace Modules
{
namespace Main
{

//   Abstract class for any input/interaction with this module.

class ControllerInterface
{
public:
	virtual void init()
	{
		throw std::domain_error("Not implemented");
	}
};
} // namespace Main
} // namespace Modules
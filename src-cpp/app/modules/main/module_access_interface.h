#pragma once

#include <stdexcept>

namespace Modules
{
namespace Main
{
class ModuleAccessInterface
{
public:
	virtual void load()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Main
}; // namespace Modules

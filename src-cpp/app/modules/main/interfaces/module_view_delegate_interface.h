#pragma once

#include <stdexcept>

namespace Modules
{
namespace Main
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad()
	{
		throw std::domain_error("Not implemented");
	}
};
}; // namespace Main
}; // namespace Modules
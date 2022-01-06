#pragma once

#include <stdexcept>

class AppService
{
public:
	virtual void init()
	{
		throw std::domain_error("Not implemented");
	}
};

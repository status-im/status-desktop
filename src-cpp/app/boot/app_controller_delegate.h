#pragma once

#include <stdexcept>

class AppControllerDelegate
{
public:
	virtual void startupDidLoad()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void mainDidLoad()
	{
		throw std::domain_error("Not implemented");
	}

	virtual void userLoggedIn()
	{
		throw std::domain_error("Not implemented");
	}
};

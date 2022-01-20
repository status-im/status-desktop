#pragma once
#include "../item.h"
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Login
{
class ModuleViewDelegateInterface
{
public:
	virtual void viewDidLoad() = 0;

	virtual void setSelectedAccount(Item item) = 0;

	virtual void login(QString password) = 0;
};
}; // namespace Login
}; // namespace Startup
}; // namespace Modules
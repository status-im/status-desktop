#pragma once

#include "app_controller_delegate.h"
#include "controller.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "interfaces/module_view_delegate_interface.h"
#include "login/module_access_interface.h"
#include "module_access_interface.h"
#include "onboarding/module_access_interface.h"
#include "view.h"
#include <QVariant>

namespace Modules
{
namespace Main
{
class Module : public ModuleAccessInterface, ModuleControllerDelegateInterface, ModuleViewDelegateInterface
{
private:
	AppControllerDelegate* m_delegate;
	View* m_view;
	Controller* m_controller;

public:
	Module(AppControllerDelegate* d);
	~Module();
	void load() override;
	void checkIfModuleDidLoad();
	void viewDidLoad() override;
};
}; // namespace Main
}; // namespace Modules
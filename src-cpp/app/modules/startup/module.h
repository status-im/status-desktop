#pragma once

#include "accounts/service_interface.h"
#include "app_controller_delegate.h"
#include "controller.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "interfaces/module_login_delegate_interface.h"
#include "interfaces/module_onboarding_delegate_interface.h"
#include "interfaces/module_view_delegate_interface.h"
#include "login/module_access_interface.h"
#include "module_access_interface.h"
#include "onboarding/module_access_interface.h"
#include "view.h"
#include <QVariant>

namespace Modules
{
namespace Startup
{
class Module : public ModuleAccessInterface,
			   ModuleOnboardingDelegateInterface,
			   ModuleLoginDelegateInterface,
			   ModuleControllerDelegateInterface,
			   ModuleViewDelegateInterface
{
private:
	AppControllerDelegate* m_delegate;
	View* m_view;
	Controller* m_controller;

	Modules::Startup::Onboarding::ModuleAccessInterface* m_onboardingModule;
	Modules::Startup::Login::ModuleAccessInterface* m_loginModule;

public:
	Module(AppControllerDelegate* d,
		   /*keychainService,*/ Accounts::ServiceInterface* accountsService);
	~Module();
	void load() override;
	void checkIfModuleDidLoad();
	void viewDidLoad() override;
	void onboardingDidLoad();
	void loginDidLoad();
	void userLoggedIn() override;
	void moveToAppState() override;
	void emitLogOut() override;
};
}; // namespace Startup
}; // namespace Modules
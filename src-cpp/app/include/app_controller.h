#pragma once

#include "accounts/service.h"
#include "module_access_interface.h"
#include "app_controller_delegate.h"
#include "app_service.h"

class AppController : public AppControllerDelegate
{
	//statusFoundation: StatusFoundation

	// Global
	//localAppSettingsVariant: QVariant
	//localAccountSettingsVariant: QVariant
	//localAccountSensitiveSettingsVariant: QVariant
	//userProfileVariant: QVariant
	//globalUtilsVariant: QVariant

	// Services
	Accounts::Service* m_accountsService;

	// Modules
	Modules::Startup::ModuleAccessInterface* m_startupModule;
	//mainModule: main_module.AccessInterface

public:
	AppController();
	~AppController();
	void start();

private:
	void connect();
	void startupDidLoad() override;
	void mainDidLoad();
	void load();
	void userLoggedIn() override;
	void buildAndRegisterLocalAccountSensitiveSettings();
	void buildAndRegisterUserProfile();
};

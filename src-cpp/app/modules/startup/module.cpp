#include "module.h"
#include "accounts/service_interface.h"
#include "controller.h"
#include "modules/startup/login/module.h"
#include "modules/startup/onboarding/module.h"
#include "singleton.h"
#include "view.h"
#include <QDebug>
#include <QObject>
#include <QQmlContext>
#include <QVariant>

namespace Modules
{
namespace Startup
{
Module::Module(AppControllerDelegate* d,
			   /*keychainService,*/
			   Accounts::ServiceInterface* accountsService)

{
	m_delegate = d;
	m_controller = new Controller(this, accountsService);
	m_view = new View(this);

	// Submodules
	m_onboardingModule = new Modules::Startup::Onboarding::Module(this, accountsService);
	m_loginModule = new Modules::Startup::Login::Module(this, /*keychainService, */ accountsService);
}

Module::~Module()
{
	delete m_controller;
	delete m_view;
	delete m_onboardingModule;
	delete m_loginModule;
}

void Module::load()
{
	Global::Singleton::instance()->engine()->rootContext()->setContextProperty("startupModule", m_view);
	m_controller->init();
	m_view->load();

	AppState initialAppState(AppState::OnboardingState);
	if(!m_controller->shouldStartWithOnboardingScreen())
	{
		initialAppState = AppState::LoginState;
	}

	m_view->setAppState(initialAppState);

	m_onboardingModule->load();
	m_loginModule->load();
}

void Module::checkIfModuleDidLoad()
{
	if(!m_onboardingModule->isLoaded())
	{
		return;
	}

	if(!m_loginModule->isLoaded())
	{
		return;
	}

	m_delegate->startupDidLoad();
}

void Module::viewDidLoad()
{
	Module::checkIfModuleDidLoad();
}

void Module::onboardingDidLoad()
{
	Module::checkIfModuleDidLoad();
}

void Module::loginDidLoad()
{
	Module::checkIfModuleDidLoad();
}

void Module::userLoggedIn()
{
	m_delegate->userLoggedIn();
}

void Module::moveToAppState()
{
	m_view->setAppState(AppState::MainAppState);
}

void Module::emitLogOut()
{
	m_view->emitLogOut();
}
} // namespace Startup
} // namespace Modules
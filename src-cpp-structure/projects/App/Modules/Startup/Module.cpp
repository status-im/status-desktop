#include "Module.h"

#include "Controller.h"
#include "View.h"

#include "../../Core/Engine.h"

using namespace Status::Modules::Startup;

Module::Module(std::shared_ptr<Startup::ModuleDelegateInterface> delegate,
               std::shared_ptr<ControllerInterface> controller,
               std::shared_ptr<ViewInterface> view,
               Onboarding::ModuleBuilder onboardingModuleBuilder,
               Login::ModuleBuilder loginModuleBuilder)
    : m_delegate(std::move(delegate))
    , m_controller(std::move(controller))
    , m_view(std::move(view))
    , m_onboardingModuleBuilder(std::move(onboardingModuleBuilder))
    , m_loginModuleBuilder(std::move(loginModuleBuilder))
{
}

void Module::load()
{
    Engine::instance()->rootContext()->setContextProperty("startupModule", m_view->getQObject());
    m_controller->init();
    m_view->load();
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
    AppState initialAppState(AppState::OnboardingState);
    if(!m_controller->shouldStartWithOnboardingScreen())
    {
        initialAppState = AppState::LoginState;
    }

    m_view->setAppState(initialAppState);


    m_onboardingModule = m_onboardingModuleBuilder(shared_from_this());
    m_loginModule = m_loginModuleBuilder(shared_from_this());

    m_onboardingModule->load();
    m_loginModule->load();

    checkIfModuleDidLoad();
}

void Module::onboardingDidLoad()
{
    checkIfModuleDidLoad();
}

void Module::loginDidLoad()
{
    checkIfModuleDidLoad();
}

void Module::userLoggedIn()
{
    m_delegate->userLoggedIn();
}

void Module::moveToAppState()
{
    m_view->setAppState(AppState::MainAppState);
}

void Module::emitLogOutSignal()
{
    m_view->emitLogOut();
}

void Module::emitStartUpUIRaisedSignal()
{
    m_view->emitStartUpUIRaised();
}

#include "ModuleBuilder.h"

#include "Module.h"
#include "Controller.h"
#include "View.h"

using namespace Status::Modules::Startup;

ModuleBuilder::ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                             Onboarding::ModuleBuilder onboardingModuleBuilder,
                             Login::ModuleBuilder loginModuleBuilder)
    : m_accountsService(std::move(accountsService))
    , m_onboardingModuleBuilder(std::move(onboardingModuleBuilder))
    , m_loginModuleBuilder(std::move(loginModuleBuilder))
{
}

std::shared_ptr<ModuleAccessInterface> ModuleBuilder::operator()(std::shared_ptr<ModuleDelegateInterface> delegate) {

    auto controller = std::make_shared<Controller>(m_accountsService);
    auto view = std::make_shared<View>();

    auto module = std::make_shared<Module>(delegate, controller, view,
                                           m_onboardingModuleBuilder, m_loginModuleBuilder);

    controller->setDelegate(module);
    view->setDelegate(module);

    return module;
}

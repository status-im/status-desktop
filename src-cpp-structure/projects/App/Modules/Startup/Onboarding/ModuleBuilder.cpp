#include "ModuleBuilder.h"

#include "Module.h"
#include "Controller.h"
#include "View.h"

using namespace Status::Modules::Startup::Onboarding;

ModuleBuilder::ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService)
    : m_accountsService(std::move(accountsService))
{
}

std::shared_ptr<ModuleAccessInterface> ModuleBuilder::operator()(std::shared_ptr<ModuleDelegateInterface> delegate) {

    auto controller = std::make_shared<Controller>(m_accountsService);
    auto view = std::make_shared<View>();

    auto module = std::make_shared<Module>(delegate, controller, view);

    controller->setDelegate(module);
    view->setDelegate(module);

    return module;
}

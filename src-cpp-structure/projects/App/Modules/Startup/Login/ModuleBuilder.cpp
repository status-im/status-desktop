#include "ModuleBuilder.h"

#include "Module.h"
#include "Controller.h"
#include "View.h"

using namespace Status::Modules::Startup::Login;

ModuleBuilder::ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                             std::shared_ptr<Keychain::ServiceInterface> keychainService)
    : m_accountsService(std::move(accountsService))
    , m_keychainService(std::move(keychainService))
{
}

std::shared_ptr<ModuleAccessInterface> ModuleBuilder::operator()(std::shared_ptr<ModuleDelegateInterface> delegate) {

    auto controller = std::make_shared<Controller>(m_accountsService, m_keychainService);
    auto view = std::make_shared<View>();

    auto module = std::make_shared<Module>(delegate, controller, view);

    controller->setDelegate(module);
    view->setDelegate(module);

    return module;
}

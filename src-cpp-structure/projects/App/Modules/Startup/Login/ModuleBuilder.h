#pragma once

#include "ModuleInterface.h"

#include <StatusServices/AccountsService>
#include <StatusServices/KeychainService>

#include <memory>

namespace Status::Modules::Startup::Login
{
    class ModuleBuilder final
    {
    public:
        ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                      std::shared_ptr<Keychain::ServiceInterface> keychainService);

        [[nodiscard]] std::shared_ptr<ModuleAccessInterface> operator()(std::shared_ptr<ModuleDelegateInterface> delegate);

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
        std::shared_ptr<Keychain::ServiceInterface> m_keychainService;
    };
}

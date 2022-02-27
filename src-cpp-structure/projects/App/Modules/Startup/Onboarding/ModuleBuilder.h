#pragma once

#include "ModuleInterface.h"

#include <StatusServices/AccountsService>

#include <memory>

namespace Status::Modules::Startup::Onboarding
{
    class ModuleBuilder final
    {
    public:
        ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService);

        [[nodiscard]] std::shared_ptr<ModuleAccessInterface> operator()(std::shared_ptr<ModuleDelegateInterface> delegate);

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
    };
}

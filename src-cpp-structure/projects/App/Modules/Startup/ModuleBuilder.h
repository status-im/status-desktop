#pragma once

#include "ModuleInterface.h"
#include "Onboarding/ModuleBuilder.h"
#include "Login/ModuleBuilder.h"

#include <StatusServices/Accounts/ServiceInterface.h>

#include <memory>

namespace Status::Modules::Startup
{
    class ModuleBuilder final
    {
    public:
        ModuleBuilder(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                      Onboarding::ModuleBuilder onboardingModuleBuilder,
                      Login::ModuleBuilder loginModuleBuilder);

        [[nodiscard]] std::shared_ptr<ModuleAccessInterface> operator()(std::shared_ptr<ModuleDelegateInterface> delegate);

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
        Onboarding::ModuleBuilder m_onboardingModuleBuilder;
        Login::ModuleBuilder m_loginModuleBuilder;
    };
}

#pragma once

#include "ModuleInterface.h"
#include "Startup/ModuleBuilder.h"

#include <memory>

namespace Status::Modules
{

    class RootModule final : public ModuleAccessInterface
            , public Startup::ModuleDelegateInterface
            , public std::enable_shared_from_this<RootModule>
    {
    public:
        RootModule(Startup::ModuleBuilder moduleBuilder);

        void load() override;
        void startupDidLoad() override;
        void userLoggedIn() override;

    private:

        Startup::ModuleBuilder m_startupModuleBuilder;
        std::shared_ptr<Startup::ModuleAccessInterface> m_startupModule;
    };
}

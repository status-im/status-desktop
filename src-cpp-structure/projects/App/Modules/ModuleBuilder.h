#pragma once

#include "ModuleInterface.h"
#include "Startup/ModuleBuilder.h"

#include <memory>

namespace Status::Modules
{

    class ModuleBuilder final
    {
    public:
        ModuleBuilder(Startup::ModuleBuilder moduleBuilder);

        [[nodiscard]] std::shared_ptr<ModuleAccessInterface> operator()();

    private:
        Startup::ModuleBuilder m_startupModuleBuilder;
    };
}

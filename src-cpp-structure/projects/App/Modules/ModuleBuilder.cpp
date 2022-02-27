#include "ModuleBuilder.h"

#include "Module.h"

using namespace Status::Modules;

ModuleBuilder::ModuleBuilder(Startup::ModuleBuilder moduleBuilder)
    : m_startupModuleBuilder(std::move(moduleBuilder))
{
}

std::shared_ptr<ModuleAccessInterface> ModuleBuilder::operator()()
{
    return std::make_shared<RootModule>(m_startupModuleBuilder);
}

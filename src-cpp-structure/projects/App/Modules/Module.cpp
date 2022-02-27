#include "Module.h"

#include "Startup/Module.h"

using namespace Status::Modules;

RootModule::RootModule(Startup::ModuleBuilder moduleBuilder)
    : m_startupModuleBuilder(std::move(moduleBuilder))
{
}

void RootModule::load()
{
    m_startupModule = m_startupModuleBuilder(shared_from_this());
    m_startupModule->load();
}

void RootModule::startupDidLoad()
{
    m_startupModule->emitStartUpUIRaisedSignal();
}

void RootModule::userLoggedIn()
{

}

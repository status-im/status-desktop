#include "Module.h"

#include "Controller.h"
#include "View.h"

#include "../../../Core/Engine.h"

using namespace Status::Modules::Startup::Onboarding;

Module::Module(std::shared_ptr<ModuleDelegateInterface> delegate,
               std::shared_ptr<ControllerInterface> controller,
               std::shared_ptr<ViewInterface> view)
    : m_delegate(std::move(delegate))
    , m_controller(std::move(controller))
    , m_view(std::move(view))
{
}

void Module::load()
{
    Engine::instance()->rootContext()->setContextProperty("onboardingModule", m_view->getQObject());
    m_controller->init();
    m_view->load();

    const QVector<Accounts::GeneratedAccountDto>& gAcc = m_controller->getGeneratedAccounts();
    QVector<Item> accounts;
    foreach(const Accounts::GeneratedAccountDto& acc, gAcc)
    {
        accounts << Item(acc.id, acc.alias, acc.identicon, acc.address, acc.keyUid);
    }

    m_view->setAccountList(accounts);
}

bool Module::isLoaded()
{
    return m_moduleLoaded;
}

void Module::viewDidLoad()
{
    m_moduleLoaded = true;
    m_delegate->onboardingDidLoad();
}

void Module::setSelectedAccountByIndex(const int index)
{
    m_controller->setSelectedAccountByIndex(index);
}

void Module::storeSelectedAccountAndLogin(const QString& password)
{
    m_controller->storeSelectedAccountAndLogin(password);
}
void Module::setupAccountError()
{
    m_view->setupAccountError();
}

const Status::Accounts::GeneratedAccountDto& Module::getImportedAccount() const
{
    return m_controller->getImportedAccount();
}

QString Module::validateMnemonic(const QString& mnemonic)
{
    return m_controller->validateMnemonic(mnemonic);
}

void Module::importMnemonic(const QString& mnemonic)
{
    m_controller->importMnemonic(mnemonic);
}

void Module::importAccountError()
{
    m_view->importAccountError();
}

void Module::importAccountSuccess()
{
    m_view->importAccountSuccess();
}

#include "Controller.h"

#include "../../../Core/GlobalEvents.h"

using namespace Status::Modules::Startup::Onboarding;

Controller::Controller(std::shared_ptr<Accounts::ServiceInterface> accountsService)
    : QObject(nullptr)
    , m_delegate(nullptr)
    , m_accountsService(std::move(accountsService))
{
}

void Controller::setDelegate(std::shared_ptr<ControllerDelegateInterface> delegate)
{
    m_delegate = std::move(delegate);
}

void Controller::init()
{
    QObject::connect(&GlobalEvents::instance(), &GlobalEvents::nodeLogin, this, &Controller::onLogin);
}

void Controller::onLogin(const QString& error)
{
    if(!error.isEmpty())
    {
        m_delegate->setupAccountError();
    }
}

const QVector<Status::Accounts::GeneratedAccountDto>& Controller::getGeneratedAccounts() const
{
    return m_accountsService->generatedAccounts();
}

const Status::Accounts::GeneratedAccountDto& Controller::getImportedAccount() const
{
    return m_accountsService->getImportedAccount();
}

void Controller::setSelectedAccountByIndex(const int index)
{
    auto accounts = getGeneratedAccounts();
    m_selectedAccountId = accounts[index].id;
}

void Controller::storeSelectedAccountAndLogin(const QString& password)
{
    if(!m_accountsService->setupAccount(m_selectedAccountId, password))
    {
        m_delegate->setupAccountError();
    }
}

QString Controller::validateMnemonic(const QString& mnemonic)
{
    return m_accountsService->validateMnemonic(mnemonic);
}

void Controller::importMnemonic(const QString& mnemonic)
{
    if(m_accountsService->importMnemonic(mnemonic))
    {
        m_selectedAccountId = getImportedAccount().id;
        m_delegate->importAccountSuccess();
    }
    else
    {
        m_delegate->importAccountError();
    }
}

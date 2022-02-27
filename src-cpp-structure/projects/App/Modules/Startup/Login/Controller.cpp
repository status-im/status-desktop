#include "Controller.h"

#include "../../../Core/GlobalEvents.h"
#include "../../../Global/LocalAccountSettings.h"

using namespace Status::Modules::Startup::Login;

Controller::Controller(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                       std::shared_ptr<Keychain::ServiceInterface> keychainService)
    : QObject(nullptr)
    , m_delegate(nullptr)
    , m_accountsService(std::move(accountsService))
    , m_keychainService(std::move(keychainService))
{
}

void Controller::setDelegate(std::shared_ptr<ControllerDelegateInterface> delegate)
{
    m_delegate = std::move(delegate);
}

void Controller::init()
{
    m_keychainService->subscribe(shared_from_this());

    QObject::connect(&GlobalEvents::instance(), &GlobalEvents::nodeLogin, this, &Controller::onLogin);
}

void Controller::onLogin(const QString& error)
{
    if(!error.isEmpty())
    {
        m_delegate->emitAccountLoginError(error);
    }
}

QVector<Status::Accounts::AccountDto> Controller::getOpenedAccounts() const
{
    return m_accountsService->openedAccounts();
}

Status::Accounts::AccountDto Controller::getSelectedAccount() const
{
    auto openedAccounts = getOpenedAccounts();
    foreach(const auto& acc, openedAccounts)
    {
        if(acc.keyUid == m_selectedAccountKeyUid)
        {
            return acc;
        }
    }

    // TODO: For situations like this, should be better to return a std::optional instead?
    return Accounts::AccountDto();
}

void Controller::setSelectedAccountKeyUid(const QString& keyUid)
{
    m_selectedAccountKeyUid = keyUid;

#ifdef Q_OS_MACOS
    // Dealing with Keychain is the MacOS only feature

    auto selectedAccount = getSelectedAccount();
    LocalAccountSettings::instance().setFileName(selectedAccount.name);

    auto value = LocalAccountSettings::instance().get_storeToKeychain();
    if (value != LocalAccountSettingsPossibleValues::StoreToKeychain::Store)
        return;

    m_keychainService->tryToObtainPassword(selectedAccount.name);
#endif
}

void Controller::login(const QString& password)
{
    auto selectedAccount = Controller::getSelectedAccount();
    auto error = m_accountsService->login(selectedAccount, password);
    if(!error.isEmpty())
    {
        m_delegate->emitAccountLoginError(error);
    }
}

void Controller::onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription)
{
    // We are notifying user only about keychain errors.
    if (errorType == Keychain::ErrorTypeAuthentication)
        return;

    LocalAccountSettings::instance().removeKey(LocalAccountSettingsKeys::storeToKeychain);
    m_delegate->emitObtainingPasswordError(errorDescription);
}

void Controller::onKeychainManagerSuccess(const QString& data)
{
    m_delegate->emitObtainingPasswordSuccess(data);
}

#include "OnboardingController.h"

#include "Accounts/AccountsServiceInterface.h"
#include "NewAccountController.h"
#include "UserAccount.h"

#include <StatusGo/SignalsManager.h>

namespace Status::Onboarding {

namespace StatusGo = Status::StatusGo;

OnboardingController::OnboardingController(AccountsServiceInterfacePtr accountsService)
    : QObject(nullptr)
    , m_accountsService(std::move(accountsService))
{
    {   // Init accounts
        std::vector<std::shared_ptr<UserAccount>> accounts;
        for(auto &account : getOpenedAccounts()) {
            accounts.push_back(std::make_shared<UserAccount>(std::make_unique<MultiAccount>(std::move(account))));
        }
        m_accounts = std::make_shared<UserAccountsModel>(std::move(accounts));
    }

    connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeLogin, this, &OnboardingController::onLogin);
}

OnboardingController::~OnboardingController()
{
    // Here to move instatiation of unique_ptrs into this compilation unit
}

void OnboardingController::onLogin(const QString& error)
{
    if(error.isEmpty())
        emit accountLoggedIn();
    else
        emit accountLoginError(error);
}

std::vector<MultiAccount> OnboardingController::getOpenedAccounts() const
{
    return m_accountsService->openAndListAccounts();
}

void OnboardingController::login(QObject* user, const QString& password)
{
    auto account = qobject_cast<UserAccount*>(user);
    assert(account != nullptr);
    auto error = m_accountsService->login(account->accountData(), password);
    if(!error.isEmpty())
        emit accountLoginError(error);
}

UserAccountsModel *OnboardingController::accounts() const
{
    return m_accounts.get();
}

NewAccountController *OnboardingController::initNewAccountController()
{
    m_newAccountController = std::make_unique<NewAccountController>(m_accountsService);
    emit newAccountControllerChanged();
    return m_newAccountController.get();
}

void OnboardingController::terminateNewAccountController()
{
    m_newAccountController.release()->deleteLater();
    emit newAccountControllerChanged();
}

NewAccountController *OnboardingController::newAccountController() const
{
    return m_newAccountController.get();
}

AccountsServiceInterfacePtr OnboardingController::accountsService() const
{
    return m_accountsService;
}

}

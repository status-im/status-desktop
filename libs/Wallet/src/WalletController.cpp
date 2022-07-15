#include "Status/Wallet/WalletController.h"
#include "NewWalletAccountController.h"

#include <StatusGo/Wallet/WalletApi.h>

#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Accounts/Accounts.h>
#include <StatusGo/Accounts/accounts_types.h>
#include <StatusGo/Metadata/api_response.h>
#include <StatusGo/Utils.h>
#include <StatusGo/Types.h>

#include <Onboarding/Common/Constants.h>

#include <QQmlEngine>
#include <QJSEngine>

namespace GoAccounts = Status::StatusGo::Accounts;
namespace GoWallet = Status::StatusGo::Wallet;
namespace UtilsSG = Status::StatusGo::Utils;
namespace StatusGo = Status::StatusGo;

namespace Status::Wallet {

WalletController::WalletController()
    : m_accounts(std::make_shared<AccountsModel>(std::move(getWalletAccounts()), "account"))
    , m_currentAccount(m_accounts->get(0))
{
}

WalletController *WalletController::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    return new WalletController();
}

NewWalletAccountController* WalletController::createNewWalletAccountController() const
{
    return new NewWalletAccountController(m_accounts);
}

QAbstractListModel* WalletController::accountsModel() const
{
    return m_accounts.get();
}

WalletAccount *WalletController::currentAccount() const
{
    return m_currentAccount.get();
}

void WalletController::setCurrentAccountIndex(int index)
{
    assert(index >= 0 && index < m_accounts->size());

    auto newCurrentAccount = m_accounts->get(index);
    if (m_currentAccount == newCurrentAccount)
        return;

    m_currentAccount = newCurrentAccount;
    emit currentAccountChanged();
}

std::vector<WalletAccountPtr> WalletController::getWalletAccounts(bool rootWalletAccountsOnly) const
{
    auto all = GoAccounts::getAccounts();
    std::vector<WalletAccountPtr> result;
    for(auto account : all) {
        if(!account.isChat && (!rootWalletAccountsOnly || account.isWallet))
            result.push_back(std::make_shared<WalletAccount>(std::move(account)));
    }
    return result;
}

}

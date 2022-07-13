#pragma once

#include "UserAccountsModel.h"

#include "Accounts/MultiAccount.h"

#include <QQmlEngine>
#include <QtQmlIntegration>

#include <memory>

namespace Status::Onboarding
{

class UserAccount;
class AccountsServiceInterface;
class NewAccountController;

/*!
 * \todo refactor and remove the requirement to build only shared_ptr instances or use a factory
 * \todo refactor unnedded multiple inheritance
 * \todo don't use DTOs in controllers, use QObjects directly
 * \todo make dependency on SignalManager explicit. Now it is hidden.
 */
class OnboardingController final : public QObject
        , public std::enable_shared_from_this<OnboardingController>
{
    Q_OBJECT

    QML_ELEMENT
    QML_UNCREATABLE("Created by Module, for now")

    Q_PROPERTY(UserAccountsModel* accounts READ accounts CONSTANT)
    Q_PROPERTY(NewAccountController* newAccountController READ newAccountController NOTIFY newAccountControllerChanged)

public:
    explicit OnboardingController(std::shared_ptr<AccountsServiceInterface> accountsService);
    ~OnboardingController();

    /// Retrieve available accounts
    std::vector<MultiAccount> getOpenedAccounts() const;

    /// Login user account
    /// TODO: \a user should be of type \c UserAccount but this doesn't work with Qt6 CMake API. Investigate and fix later on
    Q_INVOKABLE void login(QObject* user, const QString& password);

    UserAccountsModel *accounts() const;

    Q_INVOKABLE NewAccountController *initNewAccountController();
    Q_INVOKABLE void terminateNewAccountController();
    NewAccountController *newAccountController() const;
    std::shared_ptr<AccountsServiceInterface> accountsService() const;

signals:
    void accountLoggedIn();
    void accountLoginError(const QString& error);
    void obtainingPasswordError(const QString& errorDescription);
    void obtainingPasswordSuccess(const QString& password);

    void newAccountControllerChanged();

private slots:
    void onLogin(const QString& error);

private:
    const UserAccount* getSelectedAccount() const;

private:
    std::shared_ptr<AccountsServiceInterface> m_accountsService;
    std::shared_ptr<UserAccountsModel> m_accounts;

    std::unique_ptr<NewAccountController> m_newAccountController;
};

}

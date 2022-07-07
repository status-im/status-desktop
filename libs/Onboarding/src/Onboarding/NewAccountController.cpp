#include "NewAccountController.h"

#include "Accounts/AccountsService.h"

#include <StatusGo/SignalsManager.h>

#include <QtConcurrent>

namespace Status::Onboarding
{

namespace StatusGo = Status::StatusGo;

NewAccountController::NewAccountController(AccountsServiceInterfacePtr accountsService, QObject* parent)
    : m_accountsService(accountsService)
{
    connect(this, &NewAccountController::passwordChanged, this, &NewAccountController::checkAndUpdateDataValidity);
    connect(this, &NewAccountController::confirmationPasswordChanged, this, &NewAccountController::checkAndUpdateDataValidity);
    connect(this, &NewAccountController::nameChanged, this, &NewAccountController::checkAndUpdateDataValidity);
}

void NewAccountController::createAccount()
{
    // TODO: fix this after moving SingalManager to StatusGo wrapper lib
    QObject::connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeLogin, this, &NewAccountController::onNodeLogin);

    auto setupAccountFn = [this]() {
        if(m_nameIsValid && m_passwordIsValid && m_confirmationPasswordIsValid) {
            auto genAccounts = m_accountsService->generatedAccounts();
            if(genAccounts.size() > 0) {
                if(m_accountsService->setupAccountAndLogin(genAccounts[0].id, m_password, m_name))
                    return;
            }
        }
    };
    // TODO: refactor StatusGo wrapper to work with futures instead of SignalManager
    m_createAccountFuture = QtConcurrent::run(setupAccountFn)
        .then([]{ /*Nothing, we expect status-go events*/ })
        .onFailed([this] {
            emit accountCreationError();
        })
        .onCanceled([this] {
            emit accountCreationError();
        });
}

const QString &NewAccountController::password() const
{
    return m_password;
}

void NewAccountController::setPassword(const QString &newPassword)
{
    if (m_password == newPassword)
        return;
    m_password = newPassword;
    emit passwordChanged();
}

const QString &NewAccountController::confirmationPassword() const
{
    return m_confirmationPassword;
}

void NewAccountController::setConfirmationPassword(const QString &newConfirmationPassword)
{
    if (m_confirmationPassword == newConfirmationPassword)
        return;
    m_confirmationPassword = newConfirmationPassword;
    emit confirmationPasswordChanged();
}

const QString &NewAccountController::name() const
{
    return m_name;
}

void NewAccountController::setName(const QString &newName)
{
    if (m_name == newName)
        return;
    m_name = newName;
    emit nameChanged();
}

bool NewAccountController::passwordIsValid() const
{
    return m_passwordIsValid;
}

bool NewAccountController::confirmationPasswordIsValid() const
{
    return m_confirmationPasswordIsValid;
}

bool NewAccountController::nameIsValid() const
{
    return m_nameIsValid;
}

void NewAccountController::onNodeLogin(const QString& error)
{
    if(error.isEmpty())
        emit accountCreatedAndLoggedIn();
    else
        emit accountCreationError();
}

void NewAccountController::checkAndUpdateDataValidity()
{
    auto passwordValid = m_password.length() >= 6;
    if(passwordValid != m_passwordIsValid) {
        m_passwordIsValid = passwordValid;
        emit passwordIsValidChanged();
    }

    auto confirmationPasswordValid = m_password == m_confirmationPassword;
    if(confirmationPasswordValid != m_confirmationPasswordIsValid) {
        m_confirmationPasswordIsValid = confirmationPasswordValid;
        emit confirmationPasswordIsValidChanged();
    }

    auto nameValid = m_name.length() >= 10;
    if(nameValid != m_nameIsValid) {
        m_nameIsValid = nameValid;
        emit nameIsValidChanged();
    }
}

} // namespace Status::Onboarding

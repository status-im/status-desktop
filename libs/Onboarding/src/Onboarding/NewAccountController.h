#pragma once

#include "UserAccountsModel.h"

#include "Accounts/AccountsServiceInterface.h"
#include "Accounts/MultiAccount.h"

#include <QtQmlIntegration>

#include <QFuture>

#include <memory>

namespace Status::Onboarding
{

class ServiceInterface;

/*! \brief presentation layer for creation of a new account workflow
 *
 *  \todo shared functionality should be moved to Common library (e.g. Name/Picture Validation)
 */
class NewAccountController: public QObject
{
    Q_OBJECT

    QML_ELEMENT
    QML_UNCREATABLE("Created and owned externally")

    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString confirmationPassword READ confirmationPassword WRITE setConfirmationPassword NOTIFY confirmationPasswordChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool passwordIsValid READ passwordIsValid NOTIFY passwordIsValidChanged)
    Q_PROPERTY(bool confirmationPasswordIsValid READ confirmationPasswordIsValid NOTIFY confirmationPasswordIsValidChanged)
    Q_PROPERTY(bool nameIsValid READ nameIsValid NOTIFY nameIsValidChanged)

public:
    explicit NewAccountController(std::shared_ptr<AccountsServiceInterface> accountsService, QObject* parent = nullptr);

    Q_INVOKABLE void createAccount();

    const QString &password() const;
    void setPassword(const QString &newPassword);

    const QString &confirmationPassword() const;
    void setConfirmationPassword(const QString &newConfirmationPassword);

    const QString &name() const;
    void setName(const QString &newName);

    bool passwordIsValid() const;
    bool confirmationPasswordIsValid() const;
    bool nameIsValid() const;

signals:
    void passwordChanged();
    void confirmationPasswordChanged();
    void nameChanged();
    void nameIsValidChanged();
    void passwordIsValidChanged();
    void confirmationPasswordIsValidChanged();

    void accountCreatedAndLoggedIn();
    void accountCreationError();

private slots:
    void onNodeLogin(const QString& error);

private:
    void checkAndUpdateDataValidity();

    QString m_password;
    QString m_confirmationPassword;
    QString m_name;

    bool m_passwordIsValid = false;
    bool m_confirmationPasswordIsValid;
    bool m_nameIsValid = false;

    std::shared_ptr<AccountsServiceInterface> m_accountsService;
    QFuture<void> m_createAccountFuture;
};

} // namespace Status::Onboarding

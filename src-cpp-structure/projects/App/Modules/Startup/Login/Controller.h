#pragma once

#include "ControllerInterface.h"

namespace Status::Modules::Startup::Login
{
    class Controller : public QObject
            , public ControllerInterface
            , public Keychain::Listener
            , public std::enable_shared_from_this<Controller>
    {
        Q_OBJECT

    public:
        explicit Controller(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                            std::shared_ptr<Keychain::ServiceInterface> keychainService);
        void setDelegate(std::shared_ptr<ControllerDelegateInterface> delegate);

        // Controller Interface
        void init() override;
        QVector<Accounts::AccountDto> getOpenedAccounts() const override;
        void setSelectedAccountKeyUid(const QString& keyUid) override;
        void login(const QString& password) override;

        // Listener Interface
        void onKeychainManagerError(const QString& errorType, const int errorCode,
                                    const QString& errorDescription) override;
        void onKeychainManagerSuccess(const QString& data) override;

    private slots:
        void onLogin(const QString& error);

    private:
        Accounts::AccountDto getSelectedAccount() const;

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
        std::shared_ptr<Keychain::ServiceInterface> m_keychainService;
        std::shared_ptr<ControllerDelegateInterface> m_delegate;
        QString m_selectedAccountKeyUid;
    };
}

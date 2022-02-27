#pragma once

#include "ControllerInterface.h"

namespace Status::Modules::Startup::Onboarding
{
    class Controller : public QObject,
            public ControllerInterface
    {
        Q_OBJECT

    public:
        explicit Controller(std::shared_ptr<Accounts::ServiceInterface> accountsService);
        void setDelegate(std::shared_ptr<ControllerDelegateInterface> delegate);

        // Controller Interface
        void init() override;
        const QVector<Accounts::GeneratedAccountDto>& getGeneratedAccounts() const override;
        const Accounts::GeneratedAccountDto& getImportedAccount() const override;
        void setSelectedAccountByIndex(const int index) override;
        void storeSelectedAccountAndLogin(const QString& password) override;
        QString validateMnemonic(const QString& mnemonic) override;
        void importMnemonic(const QString& mnemonic) override;

    private slots:
        void onLogin(const QString& error);

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
        std::shared_ptr<ControllerDelegateInterface> m_delegate;
        QString m_selectedAccountId;
    };
}

#pragma once

#include "ViewInterface.h"

namespace Status::Modules::Startup::Onboarding
{
    class View final : public QObject
            , public ViewInterface
    {
        Q_OBJECT

        Q_PROPERTY(Model* accountsModel READ getModel NOTIFY modelChanged)
        Q_PROPERTY(QString importedAccountIdenticon READ getImportedAccountIdenticon NOTIFY importedAccountChanged)
        Q_PROPERTY(QString importedAccountAlias READ getImportedAccountAlias NOTIFY importedAccountChanged)
        Q_PROPERTY(QString importedAccountAddress READ getImportedAccountAddress NOTIFY importedAccountChanged)

    public:
        explicit View();
        void setDelegate(std::shared_ptr<ViewDelegateInterface> delegate);

        // View Interface
        QObject* getQObject() override;
        void load() override;
        Model* getModel() override;
        void setAccountList(QVector<Item> accounts) override;
        void importAccountError() override;
        void setupAccountError() override;
        void importAccountSuccess() override;

        QString getImportedAccountIdenticon() const;
        QString getImportedAccountAlias() const;
        QString getImportedAccountAddress() const;

        Q_INVOKABLE void setSelectedAccountByIndex(const int index);
        Q_INVOKABLE void storeSelectedAccountAndLogin(const QString& password);
        Q_INVOKABLE QString validateMnemonic(const QString& mnemonic);
        Q_INVOKABLE void importMnemonic(const QString& mnemonic);

    signals:
        void modelChanged();
        void importedAccountChanged();
        void accountSetupError();
        void accountImportError();

    private:
        std::shared_ptr<ViewDelegateInterface> m_delegate;
        Model* m_model {nullptr};
    };
}

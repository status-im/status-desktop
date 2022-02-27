#pragma once

#include "ViewInterface.h"

namespace Status::Modules::Startup::Login
{
    class View final : public QObject
            , public ViewInterface
    {
        Q_OBJECT

        Q_PROPERTY(SelectedAccount* selectedAccount READ getSelectedAccount NOTIFY selectedAccountChanged)
        Q_PROPERTY(Model* accountsModel READ getModel NOTIFY modelChanged)

    public:
        explicit View();
        void setDelegate(std::shared_ptr<ViewDelegateInterface> delegate);

        // View Interface
        QObject* getQObject() override;
        void load() override;
        Model* getModel() override;
        void setModelItems(QVector<Item> accounts) override;
        void setSelectedAccount(const Item& item) override;
        void emitAccountLoginError(const QString& error) override;
        void emitObtainingPasswordError(const QString& errorDescription) override;
        void emitObtainingPasswordSuccess(const QString& password) override;

        Q_INVOKABLE void setSelectedAccountByIndex(const int index);
        Q_INVOKABLE void login(const QString& password);

    signals:
        void selectedAccountChanged();
        void modelChanged();
        void accountLoginError(const QString& error);
        void obtainingPasswordError(const QString& errorDescription);
        void obtainingPasswordSuccess(const QString& password);

    private:
        SelectedAccount* getSelectedAccount();

    private:
        std::shared_ptr<ViewDelegateInterface> m_delegate;
        Model* m_model {nullptr};
        SelectedAccount* m_selectedAccount {nullptr};
    };
}

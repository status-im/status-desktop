#pragma once

#include "ControllerInterface.h"

#include <StatusServices/AccountsService>

namespace Status::Modules::Startup
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
        bool shouldStartWithOnboardingScreen() override;

    private slots:
        void onLogin(const QString& error);
        void onNodeStopped(const QString& error);
        void onNodeReady(const QString& error);

    private:
        std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
        std::shared_ptr<ControllerDelegateInterface> m_delegate;
    };
}

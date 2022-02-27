#pragma once

#include "ModuleInterface.h"
#include "ControllerInterface.h"
#include "ViewInterface.h"

namespace Status::Modules::Startup::Login
{

    class Module final : public ModuleAccessInterface
            , public ControllerDelegateInterface
            , public ViewDelegateInterface
            , public std::enable_shared_from_this<Module>
    {
    public:
        Module(std::shared_ptr<ModuleDelegateInterface> delegate,
               std::shared_ptr<ControllerInterface> controller,
               std::shared_ptr<ViewInterface> view);

        // Module Access
        void load() override;
        bool isLoaded() override;

        // Controller Delegate
        void emitAccountLoginError(const QString& error) override;
        void emitObtainingPasswordError(const QString& errorDescription) override;
        void emitObtainingPasswordSuccess(const QString& password) override;

        // View Delegate
        void viewDidLoad() override;
        void setSelectedAccount(const Item& item) override;
        void login(const QString& password) override;

    private:
        void checkIfModuleDidLoad();
        void extractImages(const Accounts::AccountDto& account, QString& thumbnailImage, QString& largeImage);

    private:
        std::shared_ptr<ModuleDelegateInterface> m_delegate;
        std::shared_ptr<ControllerInterface> m_controller;
        std::shared_ptr<ViewInterface> m_view;
        bool m_moduleLoaded {false};
    };
}

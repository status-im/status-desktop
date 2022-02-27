#pragma once

#include "ModuleInterface.h"
#include "ControllerInterface.h"
#include "ViewInterface.h"

namespace Status::Modules::Startup::Onboarding
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
        void importAccountError() override;
        void setupAccountError() override;
        void importAccountSuccess() override;

        // View Delegate
        void viewDidLoad() override;
        void setSelectedAccountByIndex(const int index) override;
        void storeSelectedAccountAndLogin(const QString& password) override;
        const Accounts::GeneratedAccountDto& getImportedAccount() const override;
        QString validateMnemonic(const QString& mnemonic) override;
        void importMnemonic(const QString& mnemonic) override;

    private:
        void checkIfModuleDidLoad();

    private:
        std::shared_ptr<ModuleDelegateInterface> m_delegate;
        std::shared_ptr<ControllerInterface> m_controller;
        std::shared_ptr<ViewInterface> m_view;
        bool m_moduleLoaded {false};
    };
}

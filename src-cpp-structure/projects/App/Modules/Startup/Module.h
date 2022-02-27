#pragma once

#include "ModuleInterface.h"
#include "ControllerInterface.h"
#include "ViewInterface.h"

#include "Onboarding/ModuleBuilder.h"
#include "Onboarding/ModuleInterface.h"
#include "Login/ModuleBuilder.h"
#include "Login/ModuleInterface.h"

#include <StatusServices/AccountsService>

namespace Status::Modules::Startup
{

    class Module final : public ModuleAccessInterface
            , public ControllerDelegateInterface
            , public ViewDelegateInterface
            , public std::enable_shared_from_this<Module>
            , public Onboarding::ModuleDelegateInterface
            , public Login::ModuleDelegateInterface
    {
    public:
        Module(std::shared_ptr<Startup::ModuleDelegateInterface> delegate,
               std::shared_ptr<ControllerInterface> controller,
               std::shared_ptr<ViewInterface> view,
               Onboarding::ModuleBuilder onboardingModuleBuilder,
               Login::ModuleBuilder loginModuleBuilder);

        // Module Access
        void load() override;
        void moveToAppState() override;
        void emitStartUpUIRaisedSignal() override;

        // Controller Delegate
        void userLoggedIn() override;
        void emitLogOutSignal() override;

        // View Delegate
        void viewDidLoad() override;

        // Onboarding Module Delegate
        void onboardingDidLoad() override;

        // Login Module Delegate
        void loginDidLoad() override;

    private:
        void checkIfModuleDidLoad();

    private:
        std::shared_ptr<Startup::ModuleDelegateInterface> m_delegate;
        std::shared_ptr<ControllerInterface> m_controller;
        std::shared_ptr<ViewInterface> m_view;

        Onboarding::ModuleBuilder m_onboardingModuleBuilder;
        std::shared_ptr<Onboarding::ModuleAccessInterface> m_onboardingModule;

        Login::ModuleBuilder m_loginModuleBuilder;
        std::shared_ptr<Login::ModuleAccessInterface> m_loginModule;
    };
}

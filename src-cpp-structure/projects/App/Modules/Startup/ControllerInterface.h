#pragma once

#include <QtCore>

namespace Status::Modules::Startup
{
    class ControllerInterface
    {
    public:
        virtual ~ControllerInterface() = default;

        virtual void init() = 0;
        virtual bool shouldStartWithOnboardingScreen() = 0;
    };

    class ControllerDelegateInterface
    {
    public:
        virtual void userLoggedIn() = 0;
        virtual void emitLogOutSignal() = 0;
    };
}

#pragma once

#include <QtCore>

namespace Status::Modules::Startup
{
    enum AppState
    {
        OnboardingState = 0,
        LoginState = 1,
        MainAppState = 2
        // TODO: is Pending
    };

    class ViewInterface
    {
    public:
        virtual ~ViewInterface() = default;

        virtual QObject* getQObject() = 0;
        virtual void emitLogOut() = 0;
        virtual void emitStartUpUIRaised() = 0;
        virtual void setAppState(AppState state) = 0;
        virtual void load() = 0;
    };

    class ViewDelegateInterface
    {
    public:
        virtual void viewDidLoad() = 0;
    };
}

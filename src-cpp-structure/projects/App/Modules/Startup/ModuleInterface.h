#pragma once

namespace Status::Modules::Startup
{
    class ModuleAccessInterface
    {
    public:
        virtual ~ModuleAccessInterface() = default;

        virtual void load() = 0;
        virtual void moveToAppState() = 0;
        virtual void emitStartUpUIRaisedSignal() = 0;
    };

    class ModuleDelegateInterface
    {
    public:
        virtual void startupDidLoad() = 0;
        virtual void userLoggedIn() = 0;
    };
}

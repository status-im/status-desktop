#pragma once

namespace Status::Modules::Startup::Login
{
    class ModuleAccessInterface
    {
    public:
        virtual ~ModuleAccessInterface() = default;

        virtual void load() = 0;
        virtual bool isLoaded() = 0;
    };

    class ModuleDelegateInterface
    {
    public:
        virtual void loginDidLoad() = 0;
    };
}

#pragma once

namespace Status::Modules
{
    class ModuleAccessInterface
    {
    public:
        virtual ~ModuleAccessInterface() = default;

        virtual void load() = 0;
    };
}

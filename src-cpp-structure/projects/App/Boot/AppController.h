#pragma once

namespace Status
{
    class AppController final
    {
    public:

        AppController();
        int exec(int& argc, char** argv);
    };
}

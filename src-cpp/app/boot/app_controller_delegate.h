#pragma once

class AppControllerDelegate
{
public:
    virtual void startupDidLoad() = 0;

    virtual void userLoggedIn() = 0;
};

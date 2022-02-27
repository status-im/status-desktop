#pragma once

#include "Model.h"
#include "SelectedAccount.h"

#include <StatusServices/AccountsService>

#include <QtCore>

namespace Status::Modules::Startup::Login
{
    class ViewInterface
    {
    public:
        virtual ~ViewInterface() = default;

        virtual QObject* getQObject() = 0;
        virtual void load() = 0;
        virtual Model* getModel() = 0;
        virtual void setModelItems(QVector<Item> accounts) = 0;
        virtual void setSelectedAccount(const Item& item) = 0;
        virtual void emitAccountLoginError(const QString& error) = 0;
        virtual void emitObtainingPasswordError(const QString& errorDescription) = 0;
        virtual void emitObtainingPasswordSuccess(const QString& password) = 0;
    };

    class ViewDelegateInterface
    {
    public:
        virtual void viewDidLoad() = 0;
        virtual void setSelectedAccount(const Item& item) = 0;
        virtual void login(const QString& password) = 0;
    };
}

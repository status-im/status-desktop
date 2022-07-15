#include "ApplicationController.h"

namespace Status::Application {

ApplicationController::ApplicationController(QObject *parent)
    : QObject{parent}
{

}

QObject *ApplicationController::statusAccount() const
{
    return m_statusAccount;
}

void ApplicationController::setStatusAccount(QObject *newStatusAccount)
{
    if (m_statusAccount == newStatusAccount)
        return;
    m_statusAccount = newStatusAccount;
    emit statusAccountChanged();
}

}

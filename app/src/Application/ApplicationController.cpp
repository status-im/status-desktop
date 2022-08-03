#include "ApplicationController.h"

#include <QtQml/QQmlEngine>

namespace Status::Application {

ApplicationController::ApplicationController(QObject *parent)
    : QObject{parent}
    , m_dataProvider(std::make_unique<DataProvider>())
{

}

void ApplicationController::initOnLogin()
{
    auto dbSettings = m_dataProvider->getSettings();
    m_dbSettings = std::make_shared<DbSettingsObj>(dbSettings);
}

QObject *ApplicationController::dbSettings() const
{
    return m_dbSettings.get();
}

QObject *ApplicationController::statusAccount() const
{
    QQmlEngine::setObjectOwnership(m_statusAccount, QQmlEngine::CppOwnership);
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

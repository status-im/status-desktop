#include "UserAccount.h"

#include "Accounts/MultiAccount.h"

namespace Status::Onboarding
{

UserAccount::UserAccount(std::unique_ptr<MultiAccount> data)
    : QObject()
    , m_data(std::move(data))
{

}

const QString &UserAccount::name() const
{
    return m_data->name;
}

const MultiAccount &UserAccount::accountData() const
{
    return *m_data;
}

void UserAccount::updateAccountData(const MultiAccount& newData)
{
    std::vector<std::function<void()>> notifyUpdates;

    *m_data = newData;

    if(newData.name != m_data->name)
        notifyUpdates.push_back([this]() { emit nameChanged(); });

}

}

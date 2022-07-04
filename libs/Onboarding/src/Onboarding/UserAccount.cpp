#include "UserAccount.h"

#include "Accounts/AccountDto.h"


namespace Status::Onboarding
{

UserAccount::UserAccount(std::unique_ptr<AccountDto> data)
    : QObject()
    , m_data(std::move(data))
{

}

const QString &UserAccount::name() const
{
    return m_data->name;
}

const AccountDto &UserAccount::accountData() const
{
    return *m_data;
}

void UserAccount::updateAccountData(const AccountDto& newData)
{
    std::vector<std::function<void()>> notifyUpdates;

    *m_data = newData;

    if(newData.name != m_data->name)
        notifyUpdates.push_back([this]() { emit nameChanged(); });

}

}

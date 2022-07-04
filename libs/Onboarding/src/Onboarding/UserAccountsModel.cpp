#include "UserAccountsModel.h"

#include <QObject>

namespace Status::Onboarding {


UserAccountsModel::UserAccountsModel(const std::vector<std::shared_ptr<UserAccount>> accounts, QObject* parent)
    : QAbstractListModel(parent)
    , m_accounts(std::move(accounts))
{
}

UserAccountsModel::~UserAccountsModel()
{
}

QHash<int, QByteArray> UserAccountsModel::roleNames() const
{
    static QHash<int, QByteArray> roles{
        {Name, "name"},
        {Account, "account"}
    };
    return roles;
}

int UserAccountsModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_accounts.size();
}

QVariant UserAccountsModel::data(const QModelIndex& index, int role) const
{
    if(!QAbstractItemModel::checkIndex(index))
        return QVariant();

    switch(static_cast<ModelRole>(role)) {
        case Name: return QVariant::fromValue(m_accounts[index.row()].get()->name());
        case Account: return QVariant::fromValue<QObject*>(m_accounts[index.row()].get());
    }
}

}

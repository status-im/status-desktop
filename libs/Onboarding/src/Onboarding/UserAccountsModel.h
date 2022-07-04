#pragma once

#include "UserAccount.h"

#include <QAbstractListModel>
#include <QQmlEngine>

namespace Status::Onboarding {

/*!
 * \brief Available UserAccount elements
 */
class UserAccountsModel : public QAbstractListModel
{
    Q_OBJECT

    QML_ELEMENT
    QML_UNCREATABLE("Created by OnboardingController")

    enum ModelRole {
        Name = Qt::UserRole + 1,
        Account
    };
public:

    explicit UserAccountsModel(const std::vector<std::shared_ptr<UserAccount>> accounts, QObject* parent = nullptr);
    ~UserAccountsModel();
    QHash<int, QByteArray> roleNames() const override;
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

private:
    const std::vector<std::shared_ptr<UserAccount>> m_accounts;
};

}

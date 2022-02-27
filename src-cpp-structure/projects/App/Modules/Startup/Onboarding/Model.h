#pragma once

#include "Item.h"

namespace Status::Modules::Startup::Onboarding
{
    class Model : public QAbstractListModel
    {
        Q_OBJECT

    public:
        enum ModelRole
        {
            Id = Qt::UserRole + 1,
            Alias,
            Identicon,
            Address,
            KeyUid
        };

        explicit Model(QObject* parent = nullptr);
        QHash<int, QByteArray> roleNames() const;
        virtual int rowCount(const QModelIndex& parent = QModelIndex()) const;
        virtual QVariant data(const QModelIndex& index, int role) const;
        void setItems(QVector<Item> items);

    private:
        QVector<Item> m_items;
    };
}

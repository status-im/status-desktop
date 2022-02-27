#pragma once

#include "Item.h"

namespace Status::Modules::Startup::Login
{
    class Model : public QAbstractListModel
    {
        Q_OBJECT

    public:
        enum ModelRole
        {
            Name = Qt::UserRole + 1,
            Identicon,
            ThumbnailImage,
            LargeImage,
            KeyUid
        };

        explicit Model(QObject* parent = nullptr);
        QHash<int, QByteArray> roleNames() const;
        virtual int rowCount(const QModelIndex& parent = QModelIndex()) const;
        virtual QVariant data(const QModelIndex& index, int role) const;
        void setItems(QVector<Item> items);
        Item getItemAtIndex(const int index) const;

    private:
        QVector<Item> m_items;
    };
}

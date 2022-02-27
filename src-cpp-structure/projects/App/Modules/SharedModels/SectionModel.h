#pragma once

#include "SectionItem.h"

#include <QtCore>

namespace Status::Shared::Models
{
    class SectionModel : public QAbstractListModel
    {
        Q_OBJECT

    public:
        enum ModelRole
        {
            Id = Qt::UserRole + 1,
            SectionType,
            Name,
            AmISectionAdmin,
            Description,
            Image,
            Icon,
            Color,
            HasNotification,
            NotificationsCount,
            Active,
            Enabled,
            Joined,
            IsMember,
            CanJoin,
            CanManageUsers,
            CanRequestAccess,
            Access,
            EnsOnly,
            MembersModel,
            PendingRequestsToJoinModel
        };

        explicit SectionModel(QObject* parent = nullptr);
        ~SectionModel() = default;

        QHash<int, QByteArray> roleNames() const override;
        int rowCount(const QModelIndex&) const override;
        QVariant data(const QModelIndex& index, int role) const override;

        void addItem(SectionItem* item);
        void setActiveSection(const QString& Id);
        QPointer<SectionItem> getActiveItem();

        // To add other api's later as needed

    private:
        QVector<SectionItem*> m_items;
    };
}

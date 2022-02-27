#pragma once

#include <QtCore>

namespace Status::Shared::Models
{
    enum SectionType
    {
        Unkown = -1,
        Chat,
        Community,
        Wallet,
        Browser,
        ProfileSettings,
        NodeManagement
    };
    class SectionItem : public QObject
    {
        Q_OBJECT
        Q_PROPERTY(QString id READ getId)
        Q_PROPERTY(int sectionType READ getSectionType)
        Q_PROPERTY(QString name READ getName)
        Q_PROPERTY(bool amISectionAdmin READ getAmISectionAdmin)
        Q_PROPERTY(QString description READ getDescription)
        Q_PROPERTY(QString image READ getImage)
        Q_PROPERTY(QString icon READ getIcon)
        Q_PROPERTY(QString color READ getColor)
        Q_PROPERTY(bool hasNotification READ getHasNotification)
        Q_PROPERTY(int notificationsCount READ getNotificationsCount)
        Q_PROPERTY(bool active READ getIsActive NOTIFY activeChanged)
        Q_PROPERTY(bool enabled READ getIsEnabled)
        Q_PROPERTY(bool joined READ getHasJoined)
        Q_PROPERTY(bool isMember READ getIsMember)
        Q_PROPERTY(bool canJoin READ getCanJoin)
        Q_PROPERTY(bool canManageUsers READ getCanManageUsers)
        Q_PROPERTY(bool canRequestAccess READ getCanRequestAccess)
        Q_PROPERTY(int access READ getAccess)
        Q_PROPERTY(bool ensOnly READ getIsEnsOnly)

    public:
        SectionItem(QObject* parent = nullptr,
                    const QString& id = "",
                    SectionType sectionType = SectionType::Unkown,
                    const QString& name = "",
                    const QString& description = "",
                    const QString& image = "",
                    const QString& icon = "",
                    const QString& color = "",
                    bool active = false,
                    bool enabled = false,
                    bool amISectionAdmin = false,
                    bool hasNotification = false,
                    int notificationsCount = 0,
                    bool isMember = false,
                    bool joined = false,
                    bool canJoin = false,
                    bool canManageUsers = false,
                    bool canRequestAccess = false,
                    int access = 0,
                    bool ensOnly = false);
        ~SectionItem() = default;

        // Getters
        SectionType getSectionType() const;
        const QString& getId() const;
        const QString& getName() const;
        bool getAmISectionAdmin() const;
        const QString& getDescription() const;
        const QString& getImage() const;
        const QString& getIcon() const;
        const QString& getColor() const;
        bool getHasNotification() const;
        int getNotificationsCount() const;
        bool getIsActive() const;
        bool getIsEnabled() const;
        bool getIsMember() const;
        bool getHasJoined() const;
        bool getCanJoin() const;
        bool getCanManageUsers() const;
        bool getCanRequestAccess() const;
        int getAccess() const;
        bool getIsEnsOnly() const;

        // Setters
        void setIsActive(bool isActive);

    signals:
        void activeChanged();

    private:
        SectionType m_sectionType;
        QString m_id;
        QString m_name;
        bool m_amISectionAdmin;
        QString m_description;
        QString m_image;
        QString m_icon;
        QString m_color;
        bool m_hasNotification;
        int m_notificationsCount;
        bool m_active;
        bool m_enabled;
        bool m_isMember;
        bool m_joined;
        bool m_canJoin;
        bool m_canManageUsers;
        bool m_canRequestAccess;
        int m_access;
        bool m_ensOnly;
        //    membersModel: user_model.Model
        //    pendingRequestsToJoinModel: PendingRequestModel
    };
}

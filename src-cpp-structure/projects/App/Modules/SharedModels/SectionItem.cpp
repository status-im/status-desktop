#include <QDebug>

#include "SectionItem.h"

using namespace Status::Shared::Models;

SectionItem::SectionItem(QObject* parent,
                         const QString& id,
                         SectionType sectionType,
                         const QString& name,
                         const QString& description,
                         const QString& image,
                         const QString& icon,
                         const QString& color,
                         bool active,
                         bool enabled,
                         bool amISectionAdmin,
                         bool hasNotification,
                         int notificationsCount,
                         bool isMember,
                         bool joined,
                         bool canJoin,
                         bool canManageUsers,
                         bool canRequestAccess,
                         int access,
                         bool ensOnly)
    : QObject(parent)
    , m_id(id)
    , m_sectionType(sectionType)
    , m_name(name)
    , m_amISectionAdmin(amISectionAdmin)
    , m_description(description)
    , m_image(image)
    , m_icon(icon)
    , m_color(color)
    , m_hasNotification(hasNotification)
    , m_notificationsCount(notificationsCount)
    , m_active(active)
    , m_enabled(enabled)
    , m_isMember(isMember)
    , m_joined(joined)
    , m_canJoin(canJoin)
    , m_canManageUsers(canManageUsers)
    , m_canRequestAccess(canRequestAccess)
    , m_access(access)
    , m_ensOnly(ensOnly)
{ }

SectionType SectionItem::getSectionType() const
{
    return m_sectionType;
}

const QString& SectionItem::getId() const
{
    return m_id;
}

const QString& SectionItem::getName() const
{
    return m_name;
}

bool SectionItem::getAmISectionAdmin() const
{
    return m_amISectionAdmin;
}

const QString& SectionItem::getDescription() const
{
    return m_description;
}

const QString& SectionItem::getImage() const
{
    return m_image;
}

const QString& SectionItem::getIcon() const
{
    return m_icon;
}

const QString& SectionItem::getColor() const
{
    return m_color;
}

bool SectionItem::getHasNotification() const
{
    return m_hasNotification;
}

int SectionItem::getNotificationsCount() const
{
    return m_notificationsCount;
}

bool SectionItem::getIsActive() const
{
    return m_active;
}

bool SectionItem::getIsEnabled() const
{
    return m_enabled;
}

bool SectionItem::getIsMember() const
{
    return m_isMember;
}

bool SectionItem::getHasJoined() const
{
    return m_joined;
}

bool SectionItem::getCanJoin() const
{
    return m_canJoin;
}

bool SectionItem::getCanManageUsers() const
{
    return m_canManageUsers;
}

bool SectionItem::getCanRequestAccess() const
{
    return m_canRequestAccess;
}

int SectionItem::getAccess() const
{
    return m_access;
}

bool SectionItem::getIsEnsOnly() const
{
    return m_ensOnly;
}

void SectionItem::setIsActive(bool isActive)
{
    if(m_active != isActive)
    {
        m_active = isActive;
        activeChanged();
    }
}

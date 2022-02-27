#include "SectionModel.h"

using namespace Status::Shared::Models;

SectionModel::SectionModel(QObject* parent)
    : QAbstractListModel(parent)
{ }

QHash<int, QByteArray> SectionModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[Id] = "id";
    roles[SectionType] = "sectionType";
    roles[Name] = "name";
    roles[AmISectionAdmin] = "amISectionAdmin";
    roles[Description] = "description";
    roles[Image] = "image";
    roles[Icon] = "icon";
    roles[Color] = "color";
    roles[HasNotification] = "hasNotification";
    roles[NotificationsCount] = "notificationsCount";
    roles[Active] = "active";
    roles[Enabled] = "enabled";
    roles[Joined] = "joined";
    roles[IsMember] = "isMember";
    roles[CanJoin] = "canJoin";
    roles[CanManageUsers] = "canManageUsers";
    roles[CanRequestAccess] = "canRequestAccess";
    roles[Access] = "access";
    roles[EnsOnly] = "ensOnly";
    roles[MembersModel] = "members";
    roles[PendingRequestsToJoinModel] = "pendingRequestsToJoin";
    return roles;
}

int SectionModel::rowCount(const QModelIndex& parent = QModelIndex()) const
{
    return m_items.size();
}

QVariant SectionModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
    {
        return QVariant();
    }

    if(index.row() < 0 || index.row() >= m_items.size())
    {
        return QVariant();
    }

    SectionItem* item = m_items.at(index.row());

    switch(role)
    {
    case Id: return item->getId();
    case SectionType: return item->getSectionType();
    case Name: return item->getName();
    case AmISectionAdmin: return item->getAmISectionAdmin();
    case Description: return item->getDescription();
    case Image: return item->getImage();
    case Icon: return item->getIcon();
    case Color: return item->getColor();
    case HasNotification: return item->getHasNotification();
    case NotificationsCount: return item->getNotificationsCount();
    case Active: return item->getIsActive();
    case Enabled: return item->getIsEnabled();
    case Joined: return item->getHasJoined();
    case IsMember: return item->getIsMember();
    case CanJoin: return item->getCanJoin();
    case CanManageUsers: return item->getCanManageUsers();
    case CanRequestAccess: return item->getCanRequestAccess();
    case Access: return item->getAccess();
    case EnsOnly: return item->getIsEnsOnly();
        // To Do
    case MembersModel: return QVariant();
    case PendingRequestsToJoinModel: return QVariant();
    }

    return QVariant();
}

void SectionModel::addItem(SectionItem* item)
{
    beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
    m_items.append(item);
    endInsertRows();
}

void SectionModel::setActiveSection(const QString& Id)
{

    for(int i = 0; i < m_items.size(); ++i)
    {
        auto newIndex = createIndex(i, 0, nullptr);
        if(m_items.at(i)->getIsActive())
        {
            m_items.at(i)->setIsActive(false);
            dataChanged(newIndex, newIndex, QVector<int>(ModelRole::Active));
        }
        if(m_items.at(i)->getId() == Id)
        {
            m_items.at(i)->setIsActive(true);
            dataChanged(newIndex, newIndex, QVector<int>(ModelRole::Active));
        }
    }
}

QPointer<SectionItem> SectionModel::getActiveItem()
{
    SectionItem* activeItem = nullptr;
    for(auto item : m_items)
    {
        if(item->getIsActive())
        {
            activeItem = item;
            break;
        }
    }
    return activeItem;
}

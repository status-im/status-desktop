#include "Status/ChatSection/ChatItem.h"

using namespace Status::ChatSection;

ChatItem::ChatItem(StatusGo::Chats::ChatDto rawData)
    : QObject(nullptr)
    , m_data(std::move(rawData))
{ }

QString ChatItem::id() const
{
    return m_data.id;
}

QString ChatItem::name() const
{
    return m_data.name;
}

void ChatItem::setName(const QString& value)
{
    if(m_data.name == value) return;
    m_data.name = value;
    emit nameChanged();
}

QString ChatItem::description() const
{
    return m_data.description;
}

void ChatItem::setDescription(const QString& value)
{
    if(m_data.description == value) return;
    m_data.description = value;
    emit descriptionChanged();
}

QColor ChatItem::color() const
{
    return m_data.color;
}

void ChatItem::setColor(const QColor& value)
{
    if(m_data.color == value) return;
    m_data.color = value;
    emit colorChanged();
}

bool ChatItem::muted() const
{
    return m_data.muted;
}

void ChatItem::setMuted(bool value)
{
    if(m_data.muted == value) return;
    m_data.muted = value;
    emit mutedChanged();
}

bool ChatItem::active() const
{
    return m_data.active;
}

void ChatItem::setActive(bool value)
{
    if(m_data.active == value) return;
    m_data.active = value;
    emit activeChanged();
}

#pragma once

#include <QtCore/QtCore>
#include <StatusGo/ChatAPI>

namespace Status::ChatSection
{

class ChatDataProvider : public QObject
{
    Q_OBJECT

public:
    ChatDataProvider();

    StatusGo::Chats::ChannelGroupDto getSectionData(const QString& sectionId) const;
};
} // namespace Status::ChatSection

#pragma once

#include <StatusGo/ChatAPI>
#include <QtCore/QtCore>

namespace Status::ChatSection {

    class ChatDataProvider: public QObject
    {
        Q_OBJECT

    public:
        ChatDataProvider();

        StatusGo::Chats::ChannelGroupDto getSectionData(const QString& sectionId) const;
    };
}

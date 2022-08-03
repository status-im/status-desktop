#pragma once

#include "ChatItem.h"
#include "ChatDataProvider.h"

#include <Helpers/QObjectVectorModel.h>

namespace Status::ChatSection {

    class ChatSectionController: public QObject
    {
        Q_OBJECT
        QML_ELEMENT

        Q_PROPERTY(QAbstractListModel* chatsModel READ chatsModel NOTIFY chatsModelChanged)
        Q_PROPERTY(ChatItem* currentChat READ currentChat NOTIFY currentChatChanged)

    public:
        ChatSectionController();

        QAbstractListModel* chatsModel() const;
        ChatItem* currentChat() const;

        Q_INVOKABLE void init(const QString& sectionId);
        Q_INVOKABLE void setCurrentChatIndex(int index);

    signals:
        void chatsModelChanged();
        void currentChatChanged();

    private:
        using ChatsModel = Helpers::QObjectVectorModel<ChatItem>;
        std::shared_ptr<ChatsModel> m_chats;
        std::unique_ptr<ChatDataProvider> m_dataProvider;
        ChatItemPtr m_currentChat;
    };
}

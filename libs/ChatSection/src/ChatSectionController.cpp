#include "Status/ChatSection/ChatSectionController.h"

using namespace Status::ChatSection;

ChatSectionController::ChatSectionController()
    : QObject(nullptr)
    , m_dataProvider(std::make_unique<ChatDataProvider>())
{
}

void ChatSectionController::init(const QString& sectionId)
{
    auto chatSectionData = m_dataProvider->getSectionData(sectionId);
    assert(chatSectionData.chats.size() > 0);
    std::vector<ChatItemPtr> model;
    for (auto c : chatSectionData.chats) {
        model.push_back(std::make_shared<ChatItem>(std::move(c)));
    }
    m_chats = std::make_shared<ChatsModel>(std::move(model), "chat");
    setCurrentChatIndex(0);
    emit chatsModelChanged();
}

QAbstractListModel* ChatSectionController::chatsModel() const
{
    return m_chats.get();
}

ChatItem* ChatSectionController::currentChat() const
{
    return m_currentChat.get();
}

void ChatSectionController::setCurrentChatIndex(int index)
{
    assert(index >= 0 && index < m_chats->size());

    auto chat = m_chats->get(index);
    if (m_currentChat == chat)
        return;

    m_currentChat = chat;
    emit currentChatChanged();
}

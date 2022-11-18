#include "Status/ChatSection/ChatSectionController.h"

#include <StatusGo/Messages/InputMessage.h>
#include <StatusGo/Messages/MessagesApi.h>
#include <StatusGo/Metadata/api_response.h>

using namespace Status::ChatSection;

ChatSectionController::ChatSectionController()
    : QObject(nullptr)
    , m_dataProvider(std::make_unique<ChatDataProvider>())
{ }

void ChatSectionController::init(const QString& sectionId)
{
    auto chatSectionData = m_dataProvider->getSectionData(sectionId);
    assert(chatSectionData.chats.size() > 0);
    std::vector<ChatItemPtr> model;
    for(auto c : chatSectionData.chats)
    {
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
    auto chat = index >= 0 && index < m_chats->size() ? m_chats->get(index) : ChatItemPtr();
    if(m_currentChat == chat) return;

    m_currentChat = chat;
    emit currentChatChanged();
}

void ChatSectionController::sendMessage(const QString &message) const
{
    namespace Messages = StatusGo::Messages;
    auto chatMessage = Messages::InputMessage::createTextMessage(message, m_currentChat->id());
    try {
        Messages::sendMessage(chatMessage);
    }
    catch(const StatusGo::CallPrivateRpcError& rpcError)
    {
        qWarning() << "Can't send message " << message
                   << " to id " << m_currentChat->id()
                   << ", error: " << rpcError.errorResponse().error.message.c_str();
    }
}

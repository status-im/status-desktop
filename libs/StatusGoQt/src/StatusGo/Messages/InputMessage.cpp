#include "InputMessage.h"

#include <Helpers/JsonMacros.h>
#include <Helpers/conversions.h>

using namespace Status::StatusGo;

Messages::InputMessage Messages::InputMessage::createTextMessage(const QString &message, const QString &chatId)
{
    return {message, chatId, ContentType::Text};
}

void Messages::to_json(json &j, const InputMessage &d)
{
    j = {
        {"chatId", d.chatId},
        {"text", d.messageText},
        {"responseTo", d.replyTo},
        {"ensName", d.ensName},
        {"contentType", d.contentType},
    };
}

void Messages::from_json(const json &j, InputMessage &d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(chatId)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(messageText, "text")
    STATUS_READ_NLOHMAN_JSON_PROPERTY(replyTo, "responseTo")
    STATUS_READ_NLOHMAN_JSON_PROPERTY(ensName)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(contentType)
}

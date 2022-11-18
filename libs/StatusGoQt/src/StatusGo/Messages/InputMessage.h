#pragma once

#include "MessageDto.h"

#include <nlohmann/json.hpp>

#include <QString>

using json = nlohmann::json;

namespace Status::StatusGo::Messages
{

struct InputMessage
{
    QString messageText;
    QString chatId;
    ContentType contentType = ContentType::Unknown;
    QString replyTo; // Id of the message that we are replying to
    QString ensName; // Ens name of the sender

    static InputMessage createTextMessage(const QString &message, const QString &chatId);
};

void to_json(json& j, const InputMessage& d);
void from_json(const json& j, InputMessage& d);

} // namespace Status::StatusGo::Messages

#pragma once

namespace Status::StatusGo::Messages
{

/// @see status-go's protocol/protobuf/chat_message.proto ContentType
enum class ContentType
{
    Unknown = 0,
    Text = 1,
    Sticker = 2,
    Status = 3,
    Emoji = 4,
    TransactionCommand = 5,
    // 6 - private
    Image = 7,
    Audio = 8,
    Community = 9,
    // 10 - private
    ContactRequest = 11,
    DiscordMessage = 12,
    IdentityVerification = 13
};

} // namespace Status::StatusGo::Messages

#pragma once

namespace Status::StatusGo::Messages
{
class InputMessage;

/// \brief Sends chat message
void sendMessage(const InputMessage &message);

} // namespace Status::StatusGo::Messages

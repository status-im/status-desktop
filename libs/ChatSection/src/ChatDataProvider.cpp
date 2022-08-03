#include "ChatDataProvider.h"

using namespace Status::ChatSection;

namespace StatusGo = Status::StatusGo;

ChatDataProvider::ChatDataProvider()
    : QObject(nullptr)
{
}

StatusGo::Chats::ChannelGroupDto ChatDataProvider::getSectionData(const QString& sectionId) const
{
    try {
        auto result = StatusGo::Chats::getChats();
        for(auto chGroup : result.allChannelGroups) {
            if (chGroup.id == sectionId)
                return chGroup;
        }
    }
    catch (std::exception& e) {
        qWarning() << "ChatDataProvider::getSectionData, error: " << e.what();
    }
    catch (...) {
        qWarning() << "ChatDataProvider::getSectionData, unknown error";
    }
    return StatusGo::Chats::ChannelGroupDto{};
}

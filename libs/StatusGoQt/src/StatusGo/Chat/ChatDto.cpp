#include "ChatDto.h"

#include <Helpers/JsonMacros.h>
#include <Helpers/conversions.h>

using namespace Status::StatusGo;

void Chats::to_json(json& j, const Category& d)
{
    j = {
        {"id", d.id},
        {"name", d.name},
        {"position", d.position},
    };
}

void Chats::from_json(const json& j, Category& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(name)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(position)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(id, "category_id", false)
    if(!j.contains("category_id"))
    {
        STATUS_READ_NLOHMAN_JSON_PROPERTY(id, "id", false)
    }
}

void Chats::to_json(json& j, const Permission& d)
{
    j = {
        {"access", d.access},
        {"ens_only", d.ensOnly},
    };
}

void Chats::from_json(const json& j, Permission& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(access, "access", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(ensOnly, "ens_only", false)
}

void Chats::to_json(json& j, const Images& d)
{
    j = {
        {"large", d.large},
        {"thumbnail", d.thumbnail},
        {"banner", d.banner},
    };
}

void Chats::from_json(const json& j, Images& d)
{
    constexpr auto large = "large";
    if(j.contains(large)) j[large].at("uri").get_to(d.large);

    constexpr auto thumbnail = "thumbnail";
    if(j.contains(thumbnail)) j[thumbnail].at("uri").get_to(d.thumbnail);

    constexpr auto banner = "banner";
    if(j.contains(banner)) j[banner].at("uri").get_to(d.banner);
}

void Chats::to_json(json& j, const ChatMember& d)
{
    j = {
        {"id", d.id},
        {"admin", d.admin},
        {"joined", d.joined},
        {"roles", d.roles},
    };
}

void Chats::from_json(const json& j, ChatMember& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(id)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(joined)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(roles)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(admin, "admin", false)
}

void Chats::to_json(json& j, const ChatDto& d)
{
    j = {
        {"id", d.id},
        {"name", d.name},
        {"description", d.description},
        {"color", d.color},
        {"emoji", d.emoji},
        {"active", d.active},
        {"timestamp", d.timestamp},
        {"lastClockValue", d.lastClockValue},
        {"deletedAtClockValue", d.deletedAtClockValue},
        {"readMessagesAtClockValue", d.readMessagesAtClockValue},
        {"unviewedMessagesCount", d.unviewedMessagesCount},
        {"unviewedMentionsCount", d.unviewedMentionsCount},
        {"canPost", d.canPost},
        {"alias", d.alias},
        {"identicon", d.icon},
        {"muted", d.muted},
        {"position", d.position},
        {"communityId", d.communityId},
        {"profile", d.profile},
        {"joined", d.joined},
        {"syncedTo", d.syncedTo},
        {"syncedFrom", d.syncedFrom},
        {"highlight", d.highlight},
        {"categoryId", d.categoryId},
        {"permissions", d.permissions},
        {"chatType", d.chatType},
        {"members", d.members},
    };
}

void Chats::from_json(const json& j, ChatDto& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(id)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(name)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(description)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(color)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(emoji)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(active)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(timestamp)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(lastClockValue)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(deletedAtClockValue)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(readMessagesAtClockValue)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(unviewedMessagesCount)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(unviewedMentionsCount)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(canPost)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(alias, "alias", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(icon, "icon", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(muted)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(position, "position", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(communityId)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(profile, "profile", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(joined)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(syncedTo)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(syncedFrom)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(highlight, "highlight", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(permissions, "permissions", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(chatType)

    STATUS_READ_NLOHMAN_JSON_PROPERTY(categoryId, "categoryId", false)
    if(!j.contains("categoryId"))
    {
        // Communities have `categoryID` and chats have `categoryId`
        // This should be fixed in status-go, but would be a breaking change
        STATUS_READ_NLOHMAN_JSON_PROPERTY(categoryId, "categoryID", false)
    }

    // Add community ID if needed
    if(!d.communityId.isEmpty() && !d.id.contains(d.communityId))
    {
        d.id = d.communityId + d.id;
    }

    constexpr auto membersKey = "members";
    if(j.contains(membersKey))
    {
        if(j[membersKey].is_array())
        {
            j.at(membersKey).get_to(d.members);
        }
        else if(j[membersKey].is_object())
        {
            auto obj = j[membersKey];
            for(json::const_iterator it = obj.cbegin(); it != obj.cend(); ++it)
            {
                ChatMember chatMember;
                it.value().get_to(chatMember);
                chatMember.id = it.key().c_str();
                d.members.emplace_back(std::move(chatMember));
            }
        }
    }
}

void Chats::to_json(json& j, const ChannelGroupDto& d)
{
    j = {
        {"id", d.id},
        {"admin", d.admin},
        {"verified", d.verified},
        {"name", d.name},
        {"description", d.description},
        {"introMessage", d.introMessage},
        {"outroMessage", d.outroMessage},
        {"canManageUsers", d.canManageUsers},
        {"color", d.color},
        {"muted", d.muted},
        {"images", d.images},
        {"permissions", d.permissions},
        {"channelGroupType", d.channelGroupType},
        {"chats", d.chats},
        {"categories", d.categories},
        {"members", d.members},
    };
}

void Chats::from_json(const json& j, ChannelGroupDto& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(admin)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(verified)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(name)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(description)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(introMessage)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(outroMessage)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(canManageUsers)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(color)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(muted)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(images)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(permissions, "permissions", false)

    STATUS_READ_NLOHMAN_JSON_PROPERTY(channelGroupType)
    if(d.channelGroupType.isEmpty()) d.channelGroupType = ChannelGroupTypeUnknown;

    constexpr auto chats = "chats";
    if(j.contains(chats))
    {
        auto obj = j[chats];
        for(json::const_iterator it = obj.cbegin(); it != obj.cend(); ++it)
        {
            ChatDto chatDto;
            it.value().get_to(chatDto);
            d.chats.emplace_back(std::move(chatDto));
        }
    }

    constexpr auto categories = "categories";
    if(j.contains(categories))
    {
        auto obj = j[categories];
        for(json::const_iterator it = obj.cbegin(); it != obj.cend(); ++it)
        {
            Category category;
            it.value().get_to(category);
            d.categories.emplace_back(std::move(category));
        }
    }

    constexpr auto membersKey = "members";
    if(j.contains(membersKey))
    {
        if(j[membersKey].is_object())
        {
            auto obj = j[membersKey];
            for(json::const_iterator it = obj.cbegin(); it != obj.cend(); ++it)
            {
                ChatMember chatMember;
                it.value().get_to(chatMember);
                chatMember.id = it.key().c_str();
                d.members.emplace_back(std::move(chatMember));
            }
        }
    }
}

void Chats::to_json(json& j, const AllChannelGroupsDto& d)
{
    j = {{"id", d.allChannelGroups}};
}

void Chats::from_json(const json& j, AllChannelGroupsDto& d)
{
    for(json::const_iterator it = j.cbegin(); it != j.cend(); ++it)
    {
        ChannelGroupDto channelGroupDto;
        it.value().get_to(channelGroupDto);
        channelGroupDto.id = it.key().c_str();
        d.allChannelGroups.emplace_back(std::move(channelGroupDto));
    }
}

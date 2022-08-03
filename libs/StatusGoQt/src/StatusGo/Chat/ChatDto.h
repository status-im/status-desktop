#pragma once

#include <nlohmann/json.hpp>

#include <vector>

#include <QColor>

using json = nlohmann::json;

namespace Status::StatusGo::Chats {

    constexpr auto ChannelGroupTypeUnknown = "unknown";
    constexpr auto ChannelGroupTypePersonal = "personal";
    constexpr auto ChannelGroupTypeCommunity = "community";

    enum ChatType
    {
        Unknown = 0,
        OneToOne = 1,
        Public = 2,
        PrivateGroupChat = 3,
        Profile = 4,
        CommunityChat = 6
    };

    struct Category {
        QString id;
        QString name;
        int position;
    };

    struct Permission {
        int access;
        bool ensOnly;
    };

    struct Images {
        QString thumbnail;
        QString large;
        QString banner;
    };

    struct ChatMember {
        QString id;
        bool admin;
        bool joined;
        std::vector<int> roles;
    };

    struct ChatDto {
        QString id; // ID is the id of the chat, for public chats it is the name e.g. status,
        // for one-to-one is the hex encoded public key and for group chats is a random
        // uuid appended with the hex encoded pk of the creator of the chat
        QString name;
        QString description;
        QColor color;
        QString emoji;
        bool active; // indicates whether the chat has been soft deleted
        ChatType chatType;
        quint64 timestamp; // indicates the last time this chat has received/sent a message
        quint64 lastClockValue; // indicates the last clock value to be used when sending messages
        quint64 deletedAtClockValue; // indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
        quint64 readMessagesAtClockValue;
        int unviewedMessagesCount;
        int unviewedMentionsCount;
        std::vector<ChatMember> members;
        QString alias;
        QString icon;
        bool muted;
        QString communityId; // set if chat belongs to a community
        QString profile;
        quint64 joined; // indicates when the user joined the chat last time
        quint64 syncedTo;
        quint64 syncedFrom;
        bool canPost;
        int position;
        QString categoryId;
        bool highlight;
        Permission permissions;
    };

    struct ChannelGroupDto {
        QString id;
        QString channelGroupType;
        bool admin;
        bool verified;
        QString name;
        QString ensName;
        QString description;
        QString introMessage;
        QString outroMessage;
        std::vector<ChatDto> chats;
        std::vector<Category> categories;
        Images images;
        Permission permissions;
        std::vector<ChatMember> members;
        bool canManageUsers;
        QColor color;
        bool muted;
        bool historyArchiveSupportEnabled;
        bool pinMessageAllMembersEnabled;
    };

    struct AllChannelGroupsDto {
        std::vector<ChannelGroupDto> allChannelGroups;
    };

    NLOHMANN_JSON_SERIALIZE_ENUM(ChatType, {
                                     {Unknown, "Unknown"},
                                     {OneToOne, "OneToOne"},
                                     {Public, "Public"},
                                     {PrivateGroupChat, "PrivateGroupChat"},
                                     {Profile, "Profile"},
                                     {CommunityChat, "CommunityChat"},
                                 })

    void to_json(json& j, const Category& d);
    void from_json(const json& j, Category& d);
    void to_json(json& j, const Permission& d);
    void from_json(const json& j, Permission& d);
    void to_json(json& j, const Images& d);
    void from_json(const json& j, Images& d);
    void to_json(json& j, const ChatMember& d);
    void from_json(const json& j, ChatMember& d);
    void to_json(json& j, const ChatDto& d);
    void from_json(const json& j, ChatDto& d);
    void to_json(json& j, const ChannelGroupDto& d);
    void from_json(const json& j, ChannelGroupDto& d);
    void to_json(json& j, const AllChannelGroupsDto& d);
    void from_json(const json& j, AllChannelGroupsDto& d);
}

import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import utils 1.0

ListModel {
    Component.onCompleted: append([
    {
        id: "id1",
        sectionType: Constants.appSection.chat,
        icon: "chat",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: true,
        notificationsCount: 442
    },
    {
        id: "id2",
        sectionType: Constants.appSection.wallet,
        icon: "wallet",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: false,
        notificationsCount: 0
    },
    {
        id: "id3",
        sectionType: Constants.appSection.profile,
        icon: "settings",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: true,
        notificationsCount: 0
    },
    {
        id: "id4",
        sectionType: Constants.appSection.node,
        icon: "node",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: false,
        hasNotification: false,
        notificationsCount: 0
    },
    {
        id: "id5",
        sectionType: Constants.appSection.communitiesPortal,
        icon: "communities",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: true,
        notificationsCount: 42
    },
    {
        id: "id6",
        sectionType: Constants.appSection.loadingSection,
        icon: "loading",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: false,
        notificationsCount: 0
    },
    {
        id: "id7",
        sectionType: Constants.appSection.swap,
        icon: "swap",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: false,
        notificationsCount: 0
    },
    {
        id: "id8",
        sectionType: Constants.appSection.market,
        icon: "market",
        image: "",
        bannerImageData: "",
        color: Theme.palette.primaryColor1,
        name: "",
        description: "",
        allMembers: [],
        activeMembersCount: 0,
        enabled: true,
        hasNotification: true,
        notificationsCount: 0
    },
    ])
}

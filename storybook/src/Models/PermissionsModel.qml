pragma Singleton

import QtQuick 2.14

import Models 1.0
import StatusQ.Core.Utils 0.1
import AppLayouts.Chat.controls.community 1.0

QtObject {
    id: root

    readonly property var permissionsModel: ListModel {
        Component.onCompleted:
        append([
                   {
                       holdingsListModel: root.createHoldingsModel1(),
                       channelsListModel: root.createChannelsModel1(),
                       permissionType: PermissionTypes.Type.Admin,
                       isPrivate: true
                   },
                   {
                       holdingsListModel: root.createHoldingsModel2(),
                       channelsListModel: root.createChannelsModel2(),
                       permissionType: PermissionTypes.Type.Member,
                       isPrivate: false
                   }
               ])
    }

    readonly property var shortPermissionsModel: ListModel {
        Component.onCompleted:
        append([
                   {
                       holdingsListModel: root.createHoldingsModel3(),
                       channelsListModel: root.createChannelsModel1(),
                       permissionType: PermissionTypes.Type.Admin,
                       isPrivate: true,
                   }
               ])
    }

    readonly property var longPermissionsModel: ListModel {
        Component.onCompleted:
        append([
                   {
                       holdingsListModel: root.createHoldingsModel4(),
                       channelsListModel: root.createChannelsModel1(),
                       permissionType: PermissionTypes.Type.Admin,
                       isPrivate: true
                   },
                   {
                       holdingsListModel: root.createHoldingsModel3(),
                       channelsListModel: root.createChannelsModel2(),
                       permissionType: PermissionTypes.Type.Member,
                       isPrivate: false
                   },
                   {
                       holdingsListModel: root.createHoldingsModel2(),
                       channelsListModel: root.createChannelsModel2(),
                       permissionType: PermissionTypes.Type.Member,
                       isPrivate: false
                   },
                   {
                       channelsListModel: root.createChannelsModel2(),
                       holdingsListModel: root.createHoldingsModel1(),
                       permissionType: PermissionTypes.Type.Member,
                       isPrivate: false
                   }
               ])
    }

    function createHoldingsModel1() {
        return [
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "socks",
                        amount: 1.2,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "zrx",
                        amount: 15,
                        available: false
                    },
                    {
                        type: HoldingTypes.Type.Collectible,
                        key: "Kitty1",
                        amount: 12,
                        available: true
                    }
                ]
    }

    function createHoldingsModel2() {
        return [
                    {
                        type: HoldingTypes.Type.Collectible,
                        key: "Kitty3",
                        amount: 50.25,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Collectible,
                        key: "Anniversary",
                        amount: 11,
                        available: false
                    }
                ]
    }

    function createHoldingsModel3() {
        return [
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "socks",
                        amount: 15,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "zrx",
                        amount: 1,
                        available: false
                    }
                ]
    }

    function createHoldingsModel4() {
        return [
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "socks",
                        amount: 15,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "zrx",
                        amount: 1,
                        available: false
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "1inch",
                        amount: 25000,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "Aave",
                        amount: 100,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "Amp",
                        amount: 2,
                        available: true
                    }
                ]
    }

    function createChannelsModel1() {
        return [
                    {
                        key: "general",
                        text: "#general",
                        color: "lightgreen",
                        emoji: "👋"
                    },
                    {
                        key: "faq",
                        text: "#faq",
                        color: "lightblue",
                        emoji: "⚽"
                    }
                ]
    }

    function createChannelsModel2() {
        return [
                    {
                        key: "socks",
                        iconSource: ModelsData.icons.socks,
                        text: "Socks"
                    }
                ]
    }
}

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
                       isPrivate: true,
                       holdingsListModel: root.createHoldingsModel1(),
                       permissionsObjectModel: {
                           key: 1,
                           text: "Become member",
                           imageSource: "in-contacts"
                       },
                       channelsListModel: root.createChannelsModel1()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel2(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   }
               ])
    }

    readonly property var shortPermissionsModel: ListModel {
        Component.onCompleted:
        append([
                   {
                       isPrivate: true,
                       holdingsListModel: root.createHoldingsModel3(),
                       permissionsObjectModel: {
                           key: 1,
                           text: "Become member",
                           imageSource: "in-contacts"
                       },
                       channelsListModel: root.createChannelsModel1()
                   }
               ])
    }

    readonly property var longPermissionsModel: ListModel {
        Component.onCompleted:
        append([
                   {
                       isPrivate: true,
                       holdingsListModel: root.createHoldingsModel4(),
                       permissionsObjectModel: {
                           key: 1,
                           text: "Become member",
                           imageSource: "in-contacts"
                       },
                       channelsListModel: root.createChannelsModel1()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel3(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel2(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel1(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   }
               ])
    }

    function createHoldingsModel1() {
        return [
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "SOCKS",
                        name: "SOCKS",
                        amount: 1.2,
                        imageSource: ModelsData.assets.socks,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.Or,
                        type: HoldingTypes.Type.Asset,
                        key: "ZRX",
                        name: "ZRX",
                        amount: 15,
                        imageSource: ModelsData.assets.zrx,
                        available: false
                    },
                    {
                        operator: OperatorsUtils.Operators.And,
                        type: HoldingTypes.Type.Collectible,
                        key: "Furbeard",
                        name: "Furbeard",
                        amount: 12,
                        imageSource: ModelsData.collectibles.kitty1,
                        available: true
                    }
                ]
    }

    function createHoldingsModel2() {
        return [
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Collectible,
                        key: "Happy Meow",
                        name: "Happy Meow",
                        amount: 50.25,
                        imageSource: ModelsData.collectibles.kitty3,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.And,
                        type: HoldingTypes.Type.Collectible,
                        key: "AMP",
                        name: "AMP",
                        amount: 11,
                        imageSource: ModelsData.assets.amp,
                        available: false
                    }
                ]
    }

    function createHoldingsModel3() {
        return [
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "uni",
                        imageSource: ModelsData.assets.uni,
                        name: "UNI",
                        amount: 15,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "eth",
                        imageSource: ModelsData.assets.eth,
                        name: "ETH",
                        amount: 1,
                        available: false
                    }
                ]
    }

    function createHoldingsModel4() {
        return [
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "uni",
                        imageSource: ModelsData.assets.uni,
                        name: "UNI",
                        amount: 15,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "eth",
                        imageSource: ModelsData.assets.eth,
                        name: "ETH",
                        amount: 1,
                        available: false
                    },
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "snt",
                        imageSource: ModelsData.assets.snt,
                        name: "SNT",
                        amount: 25000,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "uni",
                        imageSource: ModelsData.assets.dai,
                        name: "DAI",
                        amount: 100,
                        available: true
                    },
                    {
                        operator: OperatorsUtils.Operators.None,
                        type: HoldingTypes.Type.Asset,
                        key: "mana",
                        imageSource: ModelsData.assets.mana,
                        name: "MANA",
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

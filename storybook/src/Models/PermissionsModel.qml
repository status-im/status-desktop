pragma Singleton

import QtQuick 2.14

import Models 1.0
import StatusQ.Core.Utils 0.1
import AppLayouts.Communities.controls 1.0

QtObject {
    id: root

    readonly property var permissionsModelData: [
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
    ]

    readonly property var shortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: true,
        }
    ]

    readonly property var longPermissionsModelData: [
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
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        }
    ]

    readonly property var twoShortPermissionsModelData: [
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
    ]

    readonly property var twoLongPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: true
        },
        {
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        }
    ]

    readonly property var threeShortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: true
        },
        {
            holdingsListModel: root.createHoldingsModel1b(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        }
    ]

    readonly property var moreThanTwoInitialShortPermissionsModelData: [
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
        },
        {
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        },
        {
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false
        }
    ]

    readonly property ListModel permissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.permissionsModel
        }

        Component.onCompleted: {
            append(permissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var shortPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.shortPermissionsModel
        }

        Component.onCompleted: {
            append(shortPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var longPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.longPermissionsModel
        }

        Component.onCompleted: {
            append(longPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var twoShortPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.twoShortPermissionsModel
        }

        Component.onCompleted: {
            append(twoShortPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var twoLongPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.twoLongPermissionsModel
        }

        Component.onCompleted: {
            append(twoLongPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var threeShortPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.threeShortPermissionsModel
        }

        Component.onCompleted: {
            append(threeShortPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var moreThanTwoInitialShortPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.moreThanTwoInitialShortPermissionsModel
        }

        Component.onCompleted: {
            append(moreThanTwoInitialShortPermissionsModelData)
            guard.enabled = true
        }
    }

    function createHoldingsModel1() {
        return [
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "zrx",
                        amount: 15,
                        available: false
                    }
                ]
    }

    function createHoldingsModel1b() {
        return [
                    {
                        type: HoldingTypes.Type.Ens,
                        key: "Ens",
                        amount: 1,
                        available: true
                    }
                ]
    }

    function createHoldingsModel2() {
        return [
                    {
                        type: HoldingTypes.Type.Collectible,
                        key: "Kitty6",
                        amount: 50.25,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "Dai",
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
                        type: HoldingTypes.Type.Collectible,
                        key: "Kitty4",
                        amount: 50.25,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Collectible,
                        key: "SuperRare",
                        amount: 11,
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
                        key: "snt",
                        amount: 25000,
                        available: true
                    },
                    {
                        type: HoldingTypes.Type.Ens,
                        key: "ENS",
                        amount: 1,
                        available: false
                    },
                    {
                        type: HoldingTypes.Type.Asset,
                        key: "Amp",
                        amount: 2,
                        available: true
                    }
                ]
    }

    function createHoldingsModel5() {
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
                        key: "_welcome"
                    },
                    {
                        key: "_general"
                    }
                ]
    }

    function createChannelsModel2() {
        return []
    }
}

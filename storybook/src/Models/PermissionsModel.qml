pragma Singleton

import QtQuick

import Models
import StatusQ.Core.Utils
import AppLayouts.Communities.controls

import utils

QtObject {
    id: root

    readonly property var permissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        }
    ]

    readonly property var permissionsModelDataNotMet: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var privatePermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: true
        }
    ]

    readonly property var privatePermissionsModelNotMetData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        }
    ]

    readonly property var privatePermissionsMemberModelNotMetData: [
        {
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        }
    ]

    readonly property var shortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var oneChannelPermissionsModelData: [
        {
            key: "iamakey",
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        }
    ]

    readonly property var longPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var twoShortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        }
    ]

    readonly property var twoLongPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: true
        },
        {
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var threeShortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel1b(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var moreThanTwoInitialShortPermissionsModelData: [
        {
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: true,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        }
    ]

    readonly property var complexPermissionsModelData: [
        {
            id: "admin1",
            holdingsListModel: root.createHoldingsModel2b(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "admin2",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "tmaster1",
            holdingsListModel: root.createHoldingsModel2(),
            permissionType: PermissionTypes.Type.TokenMaster,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "tmaster2",
            holdingsListModel: root.createHoldingsModel3(),
            permissionType: PermissionTypes.Type.TokenMaster,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "member1",
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "member2",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var complexPermissionsModelDataNotMet: [
        {
            id: "admin1",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "admin2",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Admin,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "tmaster1",
            holdingsListModel: root.createHoldingsModel2(),
            permissionType: PermissionTypes.Type.TokenMaster,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "member1",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "member2",
            holdingsListModel: root.createHoldingsModel4(),
            channelsListModel: root.createChannelsModel2(),
            permissionType: PermissionTypes.Type.Member,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var channelsOnlyPermissionsModelData: [
        {
            id: "read1a",
            holdingsListModel: root.createHoldingsModel1b(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "read1b",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "read1c",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "read2a",
            holdingsListModel: root.createHoldingsModel2(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.Read,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "read2b",
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.Read,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost1a",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost1b",
            holdingsListModel: root.createHoldingsModel2b(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "viewAndPost2a",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost2b",
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost2c",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            permissionState: PermissionTypes.State.Approved,
            isPrivate: false,
            tokenCriteriaMet: false
        }
    ]

    readonly property var channelsOnlyPermissionsModelDataNotMet: [
        {
            id: "read1a",
            holdingsListModel: root.createHoldingsModel1b(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "read1b",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "read1c",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.Read,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "read2a",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.Read,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "read2b",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.Read,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost1a",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost1b",
            holdingsListModel: root.createHoldingsModel2b(),
            channelsListModel: root.createChannelsModel1(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            isPrivate: false,
            tokenCriteriaMet: true
        },
        {
            id: "viewAndPost2a",
            holdingsListModel: root.createHoldingsModel3(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost2b",
            holdingsListModel: root.createHoldingsModel5(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            isPrivate: false,
            tokenCriteriaMet: false
        },
        {
            id: "viewAndPost2c",
            holdingsListModel: root.createHoldingsModel1(),
            channelsListModel: root.createChannelsModel3(),
            permissionType: PermissionTypes.Type.ViewAndPost,
            isPrivate: false,
            tokenCriteriaMet: false
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

    readonly property ListModel permissionsModelNotMet: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.permissionsModelNotMet
        }

        Component.onCompleted: {
            append(permissionsModelDataNotMet)
            guard.enabled = true
        }
    }

    readonly property ListModel privatePermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.privatePermissionsModel
        }

        Component.onCompleted: {
            append(privatePermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property ListModel privatePermissionsNotMetModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.privatePermissionsNotMetModel
        }

        Component.onCompleted: {
            append(privatePermissionsModelNotMetData)
            guard.enabled = true
        }
    }

    readonly property ListModel privatePermissionsMemberNotMetModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.privatePermissionsMemberNotMetModel
        }

        Component.onCompleted: {
            append(privatePermissionsMemberModelNotMetData)
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

    readonly property var oneChannelPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.oneChannelPermissionsModel
        }

        Component.onCompleted: {
            append(oneChannelPermissionsModelData)
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

    readonly property var complexCombinedPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.complexCombinedPermissionsModel
        }

        Component.onCompleted: {
            append(complexPermissionsModelData)
            append(channelsOnlyPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var complexCombinedPermissionsModelNotMet: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.complexCombinedPermissionsModelNotMet
        }

        Component.onCompleted: {
            append(complexPermissionsModelDataNotMet)
            append(channelsOnlyPermissionsModelDataNotMet)
            guard.enabled = true
        }
    }

    readonly property var complexPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.complexPermissionsModel
        }

        Component.onCompleted: {
            append(complexPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var complexPermissionsModelNotMet: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.complexPermissionsModelNotMet
        }

        Component.onCompleted: {
            append(complexPermissionsModelDataNotMet)
            guard.enabled = true
        }
    }

    readonly property var channelsOnlyPermissionsModel: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.channelsOnlyPermissionsModel
        }

        Component.onCompleted: {
            append(channelsOnlyPermissionsModelData)
            guard.enabled = true
        }
    }

    readonly property var channelsOnlyPermissionsModelNotMet: ListModel {
        readonly property ModelChangeGuard guard: ModelChangeGuard {
            model: root.channelsOnlyPermissionsModelNotMet
        }

        Component.onCompleted: {
            append(channelsOnlyPermissionsModelDataNotMet)
            guard.enabled = true
        }
    }

    function createHoldingsModel1() {
        return [
                    {
                        type: Constants.TokenType.ERC20,
                        key: "zrx",
                        amount: 15,
                        available: false
                    }
                ]
    }

    function createHoldingsModel1b() {
        return [
                    {
                        type: Constants.TokenType.ENS,
                        key: "*.eth",
                        amount: 1,
                        available: true
                    }
                ]
    }

    function createHoldingsModel2() {
        return [
                    {
                        type: Constants.TokenType.ERC721,
                        key: "Kitty6",
                        amount: 50.25,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "Dai",
                        amount: 11,
                        available: true
                    }
                ]
    }

    function createHoldingsModel2b() {
        return [
                    {
                        type: Constants.TokenType.ERC721,
                        key: "Anniversary2",
                        amount: 1,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "stt",
                        amount: 666,
                        available: true
                    }
                ]
    }

    function createHoldingsModel3() {
        return [
                    {
                        type: Constants.TokenType.ERC721,
                        key: "Kitty4",
                        amount: 50.25,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC721,
                        key: "SuperRare",
                        amount: 11,
                        available: false
                    }
                ]
    }

    function createHoldingsModel4() {
        return [
                    {
                        type: Constants.TokenType.ERC20,
                        key: "eth",
                        amount: 15,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "stt",
                        amount: 25000,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ENS,
                        key: "foo.bar.eth",
                        amount: 1,
                        available: false
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "Amp",
                        amount: 2,
                        available: true
                    }
                ]
    }

    function createHoldingsModel5() {
        return [
                    {
                        type: Constants.TokenType.ERC20,
                        key: "eth",
                        amount: 15,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "zrx",
                        amount: 10,
                        available: false
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "1inch",
                        amount: 25000,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "Aave",
                        amount: 100,
                        available: true
                    },
                    {
                        type: Constants.TokenType.ERC20,
                        key: "Amp",
                        amount: 2,
                        available: true
                    }
                ]
    }

    function createChannelsModel() {
        return [
                    {
                        key: "general",
                        channelName: "general discussion"
                    }
                ]
    }

    function createChannelsModel1() {
        return [
                    {
                        key: "_welcome",
                        channelName: "Intro/welcome channel"
                    },
                    {
                        key: "_general",
                        channelName: "General"
                    }
                ]
    }

    function createChannelsModel2() {
        return []
    }

    function createChannelsModel3() {
        return [
                    {
                        key: "_vip",
                        channelName: "Club VIP"
                    }
                ]
    }

    function changePermissionState(model, index, permissionState) {
        model.get(index).permissionState = permissionState
    }

    function changeAllPermissionStates(model, permissionState) {
        for(let i = 0; i < model.count; i++)
            changePermissionState(model, i, permissionState)
    }
}

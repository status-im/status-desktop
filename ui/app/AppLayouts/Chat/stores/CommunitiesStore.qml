import QtQuick 2.15

import AppLayouts.Chat.controls.community 1.0

QtObject {
    id: root

    readonly property bool isOwner: false

    property var mintingModuleInst: mintingModule ?? null

    property var permissionsModel: ListModel {} // Backend permissions list object model assignment. Please check the current expected data in qml defined in `createPermissions` method
    property var permissionConflict: QtObject { // Backend conflicts object model assignment. Now mocked data.
        property bool exists: false
        property string holdings: qsTr("1 ETH")
        property string permissions: qsTr("View and Post")
        property string channels: qsTr("#general")

    }

    // TODO: Replace to real data, now dummy model
    property var  assetsModel: ListModel {
        Component.onCompleted: {
            append([
                       {
                           key: "socks",
                           iconSource: "qrc:imports/assets/png/tokens/SOCKS.png",
                           name: "Unisocks",
                           shortName: "SOCKS",
                           category: TokenCategories.Category.Community
                       },
                       {
                           key: "zrx",
                           iconSource: "qrc:imports/assets/png/tokens/ZRX.png",
                           name: "Ox",
                           shortName: "ZRX",
                           category: TokenCategories.Category.Own
                       },
                       {
                           key: "1inch",
                           iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png",
                           name: "1inch",
                           shortName: "ZRX",
                           category: TokenCategories.Category.Own
                       },
                       {
                           key: "Aave",
                           iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png",
                           name: "Aave",
                           shortName: "AAVE",
                           category: TokenCategories.Category.Own
                       },
                       {
                           key: "Amp",
                           iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png",
                           name: "Amp",
                           shortName: "AMP",
                           category: TokenCategories.Category.Own
                       }
                   ])
        }
    }

    // TODO: Replace to real data, now dummy model
    property var collectiblesModel: ListModel {
        Component.onCompleted: {
            append([
                       {
                           key: "Anniversary",
                           iconSource: "qrc:imports/assets/png/collectibles/Anniversary.png",
                           name: "Anniversary",
                           category: TokenCategories.Category.Community
                       },
                       {
                           key: "CryptoKitties",
                           iconSource: "qrc:imports/assets/png/collectibles/CryptoKitties.png",
                           name: "CryptoKitties",
                           category: TokenCategories.Category.Own,
                           subItems: [
                               {
                                   key: "Kitty1",
                                   iconSource: "qrc:imports/assets/png/collectibles/Furbeard.png",
                                   imageSource: "qrc:imports/assets/png/collectibles/FurbeardBig.png",
                                   name: "Furbeard"
                               },
                               {
                                   key: "Kitty2",
                                   iconSource: "qrc:imports/assets/png/collectibles/Magicat.png",
                                   imageSource: "qrc:imports/assets/png/collectibles/MagicatBig.png",
                                   name: "Magicat"
                               },
                               {
                                   key: "Kitty3",
                                   iconSource: "qrc:imports/assets/png/collectibles/HappyMeow.png",
                                   imageSource: "qrc:imports/assets/png/collectibles/HappyMeowBig.png",
                                   name: "Happy Meow"
                               },
                               {
                                   key: "Kitty4",
                                   iconSource: "qrc:imports/assets/png/collectibles/Furbeard.png",
                                   imageSource: "qrc:imports/assets/png/collectibles/FurbeardBig.png",
                                   name: "Furbeard-2"
                               },
                               {
                                   key: "Kitty5",
                                   iconSource: "qrc:imports/assets/png/collectibles/Magicat.png",
                                   imageSource: "qrc:imports/assets/png/collectibles/MagicatBig.png",
                                   name: "Magicat-3"
                               }
                           ]
                       },
                       {
                           key: "SuperRare",
                           iconSource: "qrc:imports/assets/png/collectibles/SuperRare.png",
                           name: "SuperRare",
                           category: TokenCategories.Category.Own
                       },
                       {
                           key: "Custom",
                           iconSource: "qrc:imports/assets/png/collectibles/SNT.png",
                           name: "Custom Collectible",
                           category: TokenCategories.Category.General
                       }
                   ])
        }
    }

    // TODO: Replace to real data, now dummy model
    property var  channelsModel: ListModel {
        ListElement { key: "welcome"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#welcome"}
        ListElement { key: "general"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#general"}
    }

    function createPermission(holdings, permissions, isPrivate, channels, index = null) {
        // TO BE REPLACED: It shold just be a call to the backend sharing `holdings`, `permissions`, `channels` and `isPrivate` properties.
        const permission = {
            isPrivate: true,
            holdingsListModel: [],
            permissionsObjectModel: {
                key: "",
                text: "",
                imageSource: ""
            },
            channelsListModel: [],
        }

        // Setting HOLDINGS:
        for (let i = 0; i < holdings.count; i++ ) {
            const entry = holdings.get(i)

            permission.holdingsListModel.push({
                type: entry.type,
                key: entry.key,
                name: entry.name,
                amount: entry.amount,
                imageSource: entry.imageSource
            })
        }

        // Setting PERMISSIONS:
        permission.permissionsObjectModel.key = permissions.key
        permission.permissionsObjectModel.text = permissions.text
        permission.permissionsObjectModel.imageSource = permissions.imageSource

        // Setting CHANNELS:
        for (let c = 0; c < channels.count; c++) {
            const entry = channels.get(c)

            permission.channelsListModel.push({
                itemId: entry.itemId,
                text: entry.text,
                emoji: entry.emoji,
                color: entry.color
            })
        }

        // Setting PRIVATE permission property:
        permission.isPrivate = isPrivate


        if (index !== null) {
            // Edit permission model:
            console.log("TODO: Edit permissions - backend call")
            root.permissionsModel.set(index, permission)
        } else {
            // Add into permission model:
            console.log("TODO: Create permissions - backend call - Now dummy data shown")
            root.permissionsModel.append(permission)
        }
    }

    function editPermission(index, holdings, permissions, channels, isPrivate) {
        // TO BE REPLACED: Call to backend
        createPermission(holdings, permissions, isPrivate, channels, index)
    }

    function duplicatePermission(index) {
        // TO BE REPLACED: Call to backend
        console.log("TODO: Duplicate permissions - backend call")
        const permission = root.permissionsModel.get(index)
        createPermission(permission.holdingsListModel, permission.permissionsObjectModel,
                         permission.isPrivate, permission.channelsListModel)
    }

    function removePermission(index) {
        console.log("TODO: Remove permissions - backend call")
        root.permissionsModel.remove(index)
    }

    // Minting tokens:
    property var mintTokensModel: mintingModuleInst ? mintingModuleInst.tokensModel : null

    function mintCollectible(address, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, network)
    {
        mintingModuleInst.mintCollectible(address, name, symbol, description, supply,
                                          infiniteSupply, transferable, selfDestruct, network)
    }
}

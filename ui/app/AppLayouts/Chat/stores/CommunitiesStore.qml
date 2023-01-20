import QtQuick 2.0

QtObject {
    id: root

    readonly property bool isOwner: false

    property var permissionsModel: ListModel {} // Backend permissions list object model assignment. Please check the current expected data in qml defined in `createPermissions` method
    property var permissionConflict: QtObject { // Backend conflicts object model assignment. Now mocked data.
        property bool exists: false
        property string holdings: qsTr("1 ETH")
        property string permissions: qsTr("View and Post")
        property string channels: qsTr("#general")

    }

    // TODO: Replace to real data, now dummy model
    property var  assetsModel: ListModel {
        ListElement {key: "socks"; iconSource: "qrc:imports/assets/png/tokens/SOCKS.png"; name: "Unisocks"; shortName: "SOCKS"; category: "Community assets"}
        ListElement {key: "zrx"; iconSource: "qrc:imports/assets/png/tokens/ZRX.png"; name: "Ox"; shortName: "ZRX"; category: "Listed assets"}
        ListElement {key: "1inch"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "1inch"; shortName: "ZRX"; category: "Listed assets"}
        ListElement {key: "Aave"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Aave"; shortName: "AAVE"; category: "Listed assets"}
        ListElement {key: "Amp"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Amp"; shortName: "AMP"; category: "Listed assets"}
    }

    // TODO: Replace to real data, now dummy model
    property var collectiblesModel: ListModel {
        ListElement {
            key: "Anniversary"
            iconSource: "qrc:imports/assets/png/collectibles/Anniversary.png"
            name: "Anniversary"
            category: "Community collectibles"
        }
        ListElement {
            key: "CryptoKitties"
            iconSource: "qrc:imports/assets/png/collectibles/CryptoKitties.png"
            name: "CryptoKitties"
            category: "Your collectibles"
            subItems: [
                ListElement {
                    key: "Kitty1"
                    iconSource: "qrc:imports/assets/png/collectibles/Furbeard.png"
                    imageSource: "qrc:imports/assets/png/collectibles/FurbeardBig.png"
                    name: "Furbeard"
                },
                ListElement {
                    key: "Kitty2"
                    iconSource: "qrc:imports/assets/png/collectibles/Magicat.png"
                    imageSource: "qrc:imports/assets/png/collectibles/MagicatBig.png"
                    name: "Magicat"
                },
                ListElement {
                    key: "Kitty3"
                    iconSource: "qrc:imports/assets/png/collectibles/HappyMeow.png"
                    imageSource: "qrc:imports/assets/png/collectibles/HappyMeowBig.png"
                    name: "Happy Meow"
                },
                ListElement {
                    key: "Kitty4"
                    iconSource: "qrc:imports/assets/png/collectibles/Furbeard.png"
                    imageSource: "qrc:imports/assets/png/collectibles/FurbeardBig.png"
                    name: "Furbeard-2"
                },
                ListElement {
                    key: "Kitty5"
                    iconSource: "qrc:imports/assets/png/collectibles/Magicat.png"
                    imageSource: "qrc:imports/assets/png/collectibles/MagicatBig.png"
                    name: "Magicat-3"
                }
            ]
        }
        ListElement {
            key: "SuperRare"
            iconSource: "qrc:imports/assets/png/collectibles/SuperRare.png";
            name: "SuperRare"
            category: "Your collectibles"
        }
        ListElement {
            key: "Custom"
            iconSource: "qrc:imports/assets/png/collectibles/SNT.png"
            name: "Custom Collectible"
            category: "All collectibles"
        }
    }

    // TODO: Replace to real data, now dummy model
    property var  channelsModel: ListModel {
        ListElement { key: "welcome"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#welcome"}
        ListElement { key: "general"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#general"}
    }

    function createPermission(holdings, permissions, isPrivate, channels, index = null) {
        // TO BE REPLACED: It shold just be a call to the backend sharing `holdings`, `permissions`, `channels` and `isPrivate` properties.
        var permission = {
            isPrivate: true,
            holdingsListModel: [],
            permissionsObjectModel: {
                key: "",
                text: "",
                imageSource: ""
            },
            channelsListModel: []
        };

        // Setting HOLDINGS:
        for (var i = 0; i < holdings.count; i++ ) {
            var entry = holdings.get(i);
             // roles: type, key, name, amount, imageSource
            permission.holdingsListModel.push({
                                                  type: entry.type,
                                                  key: entry.key,
                                                  name: entry.name,
                                                  amount: entry.amount,
                                                  imageSource: entry.imageSource
                                          });
        }

        // Setting PERMISSIONS:
        permission.permissionsObjectModel.key = permissions.key
        permission.permissionsObjectModel.text = permissions.text
        permission.permissionsObjectModel.imageSource = permissions.imageSource

        // Setting PRIVATE permission property:
        permission.isPrivate = isPrivate

        // TODO: Set channels list. Now mocked data.
        permission.channelsListModel = root.channelsModel

        if(index !== null) {
            // Edit permission model:
            console.log("TODO: Edit permissions - backend call")
            root.permissionsModel.set(index, permission)
        }
        else {
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
        createPermission(permission.holdingsListModel, permission.permissionsObjectModel, permission.isPrivate, permission.channelsListModel)
    }

    function removePermission(index) {
        console.log("TODO: Remove permissions - backend call")
        root.permissionsModel.remove(index)
    }
}

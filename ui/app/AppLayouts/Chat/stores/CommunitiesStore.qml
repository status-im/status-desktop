import QtQuick 2.0

import AppLayouts.Chat.controls.community 1.0
import StatusQ.Core.Utils 0.1 as SQ
import utils 1.0

QtObject {
    id: root

    property var permissionsModel: ListModel {} // Backend permissions list object model asignement. Please check the current expected data in qml defined in `createPermissions` method

    // TODO: Replace to real data, now dummy model
    property var  tokensModel: ListModel {
        ListElement {key: "socks"; iconSource: "qrc:imports/assets/png/tokens/SOCKS.png"; name: "Unisocks"; shortName: "SOCKS"; category: "Community tokens"}
        ListElement {key: "zrx"; iconSource: "qrc:imports/assets/png/tokens/ZRX.png"; name: "Ox"; shortName: "ZRX"; category: "Listed tokens"}
        ListElement {key: "1inch"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "1inch"; shortName: "ZRX"; category: "Listed tokens"}
        ListElement {key: "Aave"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Aave"; shortName: "AAVE"; category: "Listed tokens"}
        ListElement {key: "Amp"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "Amp"; shortName: "AMP"; category: "Listed tokens"}
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
        ListElement { key: "wellcome"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#welcome"}
        ListElement { key: "general"; iconSource: "qrc:imports/assets/png/tokens/CUSTOM-TOKEN.png"; name: "#general"}
    }

    readonly property QtObject _d: QtObject {
        id: d

        function getByKey(model, key) {
            for (let i = 0; i < model.count; i++) {
                const item = model.get(i)
                if (item.key === key)
                    return item
            }

            return null
        }
    }

    function getTokenByKey(key) {
        return d.getByKey(tokensModel, key)
    }

    function getCollectibleByKey(key) {
        for (let i = 0; i < collectiblesModel.count; i++) {
            const item = collectiblesModel.get(i)

            if (!!item.subItems) {
                const sub = d.getByKey(item.subItems, key)
                if (sub)
                    return sub
            } else if (item.key === key) {
                return item
            }
        }

        return null
    }

    function createPermissions(holdings, permissions, isPrivate) {
        console.log("TODO: Create permissions - backend call - Now dummy data shown")
        // TO BE REMOVED: It shold just be a call to the backend sharing `holdings`, `permissions`, `channels` and `isPrivate` properties.
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
             // roles: type, key, name, amount, imageSource, operator
            permission.holdingsListModel.push({
                                                  operator: entry.operator,
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

        // Add into permission model:
        root.permissionsModel.append(permission)
    }

    function setHoldingsTextFormat(type, name, amount) {
        switch (type) {
            case HoldingTypes.Type.Token:
            case HoldingTypes.Type.Collectible:
                return `${LocaleUtils.numberToLocaleString(amount)} ${name}`
            case HoldingTypes.Type.Ens:
                if (name)
                    return qsTr("ENS username on '%1' domain").arg(name)
                else
                    return qsTr("Any ENS username")
            default:
                return ""
        }
    }

    function editPermission(index) {
        console.log("TODO: Edit permissions - backend call")
    }

    function duplicatePermission(index) {
        console.log("TODO: Duplicate permissions - backend call")
    }

    function removePermission(index) {
        console.log("TODO: Remove permissions - backend call")
    }
}

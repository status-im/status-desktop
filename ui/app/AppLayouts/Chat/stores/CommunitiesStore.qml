import QtQuick 2.0

QtObject {

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

    function createPermissions(permissions) {
        console.log("TODO: Create permissions - backend call")
    }
}

import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import "../controls"

Item {
    id: collectiblesContainer

    property url collectibleIconSource: "CryptoKitties"
    property string collectibleName: "CryptoKitties"
    property bool collectiblesOpened: false
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}
    property var collectibles: {
        if (error) {
            return []
        }

        try {
            var result = JSON.parse(collectiblesJSON)
            if (typeof result === "string") {
                return JSON.parse(result)
            }
            return result
        } catch (e) {
            console.error('Error parsing collectibles for:', collectibleName)
            console.error('JSON:', collectiblesJSON)
            console.error('Error:', e)
            return []
        }
    }
    // Adding active instead of just using visible, because visible counts as false when the parent is not visible
    property bool active: !!loading || !!error || collectibles.length > 0

    signal reloadCollectibles(string collectibleType)

    visible: active
    width: parent.width
    height: visible ? collectiblesHeader.height + collectiblesContent.height : 0

    CollectiblesHeader {
        id: collectiblesHeader
        collectibleName: collectiblesContainer.collectibleName
        collectibleIconSource: collectiblesContainer.collectibleIconSource
        collectiblesQty: collectibles.length
        isLoading: loading
        toggleCollectible: function () {
            collectiblesContainer.collectiblesOpened = !collectiblesContainer.collectiblesOpened
        }
    }

    CollectiblesContent {
        id: collectiblesContent
        visible: collectiblesContainer.collectiblesOpened
        collectiblesModal: collectiblesContainer.collectiblesModal
        buttonText: collectiblesContainer.buttonText
        getLink: collectiblesContainer.getLink()
        anchors.top: collectiblesHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        collectibles: collectiblesContainer.collectibles
        onReloadCollectibles: reloadCollectibles(collectibleType)
    }
}

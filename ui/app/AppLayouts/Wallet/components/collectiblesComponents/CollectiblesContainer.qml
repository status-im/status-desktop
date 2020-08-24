import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Item {
    property url collectibleIconSource: "../../../../img/collectibles/CryptoKitties.png"
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

    id: root
    visible: active
    width: parent.width
    height: visible ? collectiblesHeader.height + collectiblesContent.height : 0

    CollectiblesHeader {
        id: collectiblesHeader
        collectibleName: root.collectibleName
        collectibleIconSource: root.collectibleIconSource
        collectiblesQty: collectibles.length
        isLoading: loading
        toggleCollectible: function () {
            root.collectiblesOpened = !root.collectiblesOpened
        }
    }

    CollectiblesContent {
        id: collectiblesContent
        visible: root.collectiblesOpened
        collectiblesModal: root.collectiblesModal
        buttonText: root.buttonText
        getLink: root.getLink
        anchors.top: collectiblesHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        collectibles: root.collectibles
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

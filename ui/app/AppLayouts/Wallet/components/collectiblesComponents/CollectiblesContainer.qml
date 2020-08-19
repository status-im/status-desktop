import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Item {
    property url collectibleIconSource: "../../../../img/collectibles/CryptoKitties.png"
    property string collectibleName: "CryptoKitties"
    property string collectibleType: "cryptokitty"
    property bool isLoading: true
    property bool collectiblesOpened: false
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}

    id: root
    visible: isLoading || collectiblesContent.collectiblesQty > 0
    width: parent.width
    height: visible ? collectiblesHeader.height + collectiblesContent.height : 0

    CollectiblesHeader {
        id: collectiblesHeader
        collectibleName: root.collectibleName
        collectibleIconSource: root.collectibleIconSource
        collectiblesQty: collectiblesContent.collectiblesQty
        isLoading: root.isLoading
        toggleCollectible: function () {
            root.collectiblesOpened = !root.collectiblesOpened
        }
    }

    CollectiblesContent {
        id: collectiblesContent
        visible: root.collectiblesOpened
        collectiblesModal: root.collectiblesModal
        collectibleType: root.collectibleType
        buttonText: root.buttonText
        getLink: root.getLink
        anchors.top: collectiblesHeader.bottom
        anchors.topMargin: Style.current.halfPadding
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

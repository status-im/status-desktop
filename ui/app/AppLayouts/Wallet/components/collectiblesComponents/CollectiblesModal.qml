import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    property string collectibleName: "Furbeard"
    property string collectibleId: "1423"
    property url collectibleImage: "../../../../img/collectibles/placeholders/kitty.png"
    property string collectibleDescription: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
    property string buttonText: "View in Cryptokitties"
    property string buttonLink: "https://www.cryptokitties.co/"
    property var openModal: function (options) {
        popup.collectibleName = options.name
        popup.collectibleId = options.id
        popup.collectibleDescription = options.description
        popup.collectibleImage = options.image
        //% "View"
        popup.buttonText = options.buttonText || qsTrId("view")
        popup.buttonLink = options.link
        popup.open()
    }

    id: popup
    //% "Unnamed"
    title: collectibleName || qsTrId("unnamed")

    CollectiblesModalContent {
        collectibleName: popup.collectibleName
        collectibleId: popup.collectibleId
        collectibleImage: popup.collectibleImage
        collectibleDescription: popup.collectibleDescription
    }

    footer: StatusButton {
        visible: !!popup.buttonLink
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: popup.buttonText
        anchors.top: parent.top
        onClicked: {
            appMain.openLink(popup.buttonLink)
        }
    }
}


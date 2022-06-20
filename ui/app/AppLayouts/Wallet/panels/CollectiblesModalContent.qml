import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

Item {
    property string collectibleName: "Furbeard"
    property string collectibleId: "1423"
    property url collectibleImage: Style.png("collectibles/placeholders/kitty")
    property string collectibleDescription: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"

    id: root
    width: parent.width

    RoundedImage {
        id: collectibleImage
        width: Style.dp(248)
        height: Style.dp(248)
        anchors.horizontalCenter: parent.horizontalCenter
        source: root.collectibleImage
        radius: Style.dp(16)
        fillMode: Image.PreserveAspectCrop
    }

    TextWithLabel {
        id: idText
        //% "ID"
        label: qsTrId("id")
        text: root.collectibleId
        anchors.top: collectibleImage.bottom
    }


    TextWithLabel {
        visible: !!root.collectibleDescription
        id: descriptionText
        //% "Description"
        label: qsTrId("description")
        text: root.collectibleDescription
        anchors.top: idText.bottom
        wrap: true
    }
}

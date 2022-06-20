import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.popups 1.0
import shared.panels 1.0
import shared.status 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: root
    title: root.name || qsTr("unnamed")
    property string name: "Furbeard"

    property string collectibleId: "1423"
    property url imageUrl: ""
    property string description: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
    property string permalink: "https://www.cryptokitties.co/"
    property var openModal: function (options) {
        root.name = options.name;
        root.collectibleId = options.collectibleId;
        root.description = options.description;
        root.imageUrl = options.imageUrl;
        root.permalink = options.permalink;
        root.open();
    }

    Item {
        width: parent.width

        RoundedImage {
            id: collectibleImage
            width: Style.dp(248)
            height: Style.dp(248)
            anchors.horizontalCenter: parent.horizontalCenter
            radius: Style.dp(16)
            fillMode: Image.PreserveAspectCrop
            source: root.imageUrl
        }

        TextWithLabel {
            id: idText
            anchors.top: collectibleImage.bottom
            label: qsTr("id")
            text: root.collectibleId
        }


        TextWithLabel {
            id: description
            anchors.top: idText.bottom
            visible: !!root.description
            wrap: true
            label: qsTr("description")
            text: root.description
        }
    }

    footer: StatusButton {
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: qsTr("View in Opensea")
        onClicked: {
            Global.openLink(root.permalink);
            root.close();
        }
    }
}


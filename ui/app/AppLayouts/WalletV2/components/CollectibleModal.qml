import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: root
    property string name: "Furbeard"
    property string collectibleId: "1423"
    property url imageUrl: ""
    property string description: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
    property string permalink: "https://www.cryptokitties.co/"
    property var openModal: function (options) {
        root.name = options.name
        root.collectibleId = options.collectibleId
        root.description = options.description
        root.imageUrl = options.imageUrl
        root.permalink = options.permalink
        root.open()
    }

    title: root.name || qsTr("unnamed")

    Item {
        width: parent.width

        RoundedImage {
            id: collectibleImage
            width: 248
            height: 248
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.imageUrl
            radius: 16
            fillMode: Image.PreserveAspectCrop
        }

        TextWithLabel {
            id: idText
            label: qsTr("id")
            text: root.collectibleId
            anchors.top: collectibleImage.bottom
            anchors.topMargin:0
        }


        TextWithLabel {
            id: description
            visible: !!root.description
            label: qsTr("description")
            text: root.description
            anchors.top: idText.bottom
            anchors.topMargin: 0
            wrap: true
        }
    }

    footer: StatusButton {
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: qsTr("View in Opensea")
        anchors.top: parent.top
        onClicked: {
            appMain.openLink(root.permalink)
            root.close()
        }
    }
}


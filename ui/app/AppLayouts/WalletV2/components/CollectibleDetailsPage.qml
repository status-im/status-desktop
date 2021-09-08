import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Item {
    id: collectiblesDetailContainer

    visible: false

    function show(options) {
        visible = true

        collectibleHeader.image.source = options.collectibleImageUrl
        collectibleHeader.primaryText = options.name
        collectibleHeader.secondaryText = options.collectibleId

        collectibleimage.image.source = options.imageUrl
        collectibleText.text = options.description
    }

    function hide() {
        visible = false
    }

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.right: parent.right
        anchors.rightMargin: 79
        anchors.left: parent.left
        anchors.leftMargin: 79
        anchors.top: parent.top
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 83
        anchors.right: parent.right
        anchors.rightMargin: 78
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: 46

        Row {
            id: collectibleImageDetails
            anchors.top: parent.top
            width: parent.width
            spacing: 24

            // To-do update color of background once design is finalized
            StatusRoundedImage {
                id: collectibleimage
                width: 253
                height: 253
                radius: 2
                color: "transparent"
                border.color: Theme.palette.directColor8
                border.width: 1
            }
            StatusBaseText {
                id: collectibleText
                width: parent.width - collectibleimage.width - 24
                height: collectibleimage.height

                text: qsTr("Collectibles")
                color: Theme.palette.directColor1
                font.pixelSize: 15
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }

        Column {
            anchors.top: collectibleImageDetails.bottom
            anchors.topMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                primaryText: qsTr("Properties")
                type: StatusExpandableItem.Type.Tertiary
                expandableComponent: notImplemented
            }
            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                primaryText: "Data group 2"
                type: StatusExpandableItem.Type.Tertiary
                expandableComponent: notImplemented
            }
            StatusExpandableItem {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                primaryText: "Data group 3"
                type: StatusExpandableItem.Type.Tertiary
                expandableComponent: notImplemented
            }
        }
    }

    Component {
        id: notImplemented
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: infoText.implicitHeight
            color: Theme.palette.baseColor5
            StatusBaseText {
                id: infoText
                anchors.centerIn: parent
                color: Theme.palette.directColor4
                font.pixelSize: 15
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                font.weight: Font.Medium
                text: qsTr("Not Implemented")
            }
        }
    }
}

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Item {
    id: collectiblesDetailHeader

    property alias primaryText: collectibleName.text
    property alias secondaryText: collectibleId.text

    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
    }

    height: childrenRect.height

    Layout.fillHeight: true
    Layout.fillWidth: true

    Row {
        id: backButtonRow
        anchors.top: parent.top
        anchors.topMargin: 19
        anchors.left: parent.left
        spacing: 8
        StatusIcon {
            id: arrowIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            icon: "chevron-up"
            rotation: 270
            color: Theme.palette.primaryColor1
        }
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            id: collectiblesText
            font.weight: Font.Medium
            font.pixelSize: 15
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.primaryColor1
            text: qsTr("Collectibles")
        }
    }

    MouseArea {
        anchors.fill: backButtonRow
        onClicked: {
            hide()
        }
    }

    Row {
        id: collectibleRow
        anchors.top: parent.top
        anchors.topMargin: 63
        anchors.left: parent.left
        width: parent.width - sendButton.width

        spacing: 8

        Loader {
            id: identiconLoader
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: !!collectiblesDetailHeader.image.source.toString() ? roundedImage : statusLetterIdenticonCmp
        }

        StatusBaseText {
            id: collectibleName
            width: Math.min(parent.width - identiconLoader.width - collectibleId.width - 24, implicitWidth)
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 28
            lineHeight: 38
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            id: collectibleId
            anchors.verticalCenter: collectibleName.verticalCenter
            font.pixelSize: 28
            lineHeight: 38
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.baseColor1
        }
    }

    Component {
        id: roundedImage
        StatusRoundedImage {
            image.source: collectiblesDetailHeader.image.source
        }
    }

    Component {
        id: statusLetterIdenticonCmp
        StatusLetterIdenticon {
            width: 40
            height: 40
            letterSize: 20
            color: Theme.palette.miscColor5
            name: collectibleName.text
        }
    }

    StatusButton {
        id: sendButton
        anchors.bottom: collectibleRow.bottom
        anchors.right: parent.right
        icon.name: "send"
        text: qsTr("Send")
        onClicked: () => console.log("TODO");
    }
}

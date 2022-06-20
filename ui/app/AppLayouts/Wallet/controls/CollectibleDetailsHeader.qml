import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Item {
    id: collectiblesDetailHeader
    height: childrenRect.height

    property alias primaryText: collectibleName.text
    property alias secondaryText: collectibleId.text
    property StatusImageSettings image: StatusImageSettings {
        width: Style.dp(40)
        height: Style.dp(40)
    }
    signal hideButtonClicked()

    Row {
        id: collectibleRow
        anchors.top: parent.top
        anchors.topMargin: Style.dp(63)
        anchors.left: parent.left
        width: parent.width - sendButton.width

        spacing: Style.dp(8)

        Loader {
            id: identiconLoader
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: !!collectiblesDetailHeader.image.source.toString() ? roundedImage : statusLetterIdenticonCmp
        }

        StatusBaseText {
            id: collectibleName
            width: Math.min(parent.width - identiconLoader.width - collectibleId.width - 24, implicitWidth)
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.dp(28)
            lineHeight: Style.dp(38)
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            id: collectibleId
            anchors.verticalCenter: collectibleName.verticalCenter
            font.pixelSize: Style.dp(28)
            lineHeight: Style.dp(38)
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
            width: Style.dp(40)
            height: Style.dp(40)
            letterSize: Style.dp(20)
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
        onClicked: { console.log("TODO"); }
    }
}

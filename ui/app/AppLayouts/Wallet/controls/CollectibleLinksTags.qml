import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils

Control {
    id: root

    property alias primaryText: primaryText.text
    property alias primaryLabel: primaryText
    property alias secondaryText: secondaryText.text
    property alias secondaryLabel: secondaryText
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 16
        height: 16
        name: ""
        color:  StatusColors.transparent
        isLetterIdenticon: false
        letterSize: charactersLen > 1 ? 8 : 11
        imgIsIdenticon: false
    }

    signal clicked()

    implicitWidth: 290
    implicitHeight: 64
    topPadding: 15
    bottomPadding: 15
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        radius: Theme.radius
        border.width: 1
        border.color: Theme.palette.baseColor2
        color: mouse.containsMouse ? Theme.palette.baseColor2 : StatusColors.transparent
        StatusMouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.clicked()
        }
    }

    contentItem: RowLayout {
        spacing: 8
        StatusSmartIdenticon {
            id: identicon
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: active ? 16 : 0
            Layout.preferredHeight: 16
            asset: root.asset
        }
        Column {
            Layout.fillWidth: true
            spacing: 0
            StatusBaseText {
                id: primaryText
                width: parent.width
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                color: Theme.palette.directColor1
                visible: text
                elide: Text.ElideRight
            }
            StatusBaseText {
                id: secondaryText
                width: parent.width
                font.pixelSize: Theme.tertiaryTextFontSize
                lineHeight: 16
                lineHeightMode: Text.FixedHeight
                color: Theme.palette.baseColor1
                visible: text
                elide: Text.ElideMiddle
            }
        }
        StatusRoundIcon {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            visible: root.hovered
            asset.name: "external"
            asset.color: Theme.palette.directColor1
            asset.bgColor: StatusColors.transparent
        }
    }
}

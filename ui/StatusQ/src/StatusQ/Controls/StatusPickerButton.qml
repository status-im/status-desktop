import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Button {
    id: root

    property color bgColor: Theme.palette.baseColor2
    property color contentColor: Theme.palette.baseColor1
    property var type: StatusPickerButton.Type.Next

    /*!
       \qmlproperty StatusAssetSettings StatusPickerButton::image
       This property holds the image settings information.
    */
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 20
        height: 20
        imgIsIdenticon: false
    }

    enum Type {
        Next,
        Down
    }

    implicitWidth: 446
    implicitHeight: 44
    font.pixelSize: 15
    horizontalPadding: 16
    spacing: 4
    icon.width: 16
    icon.height: 16
    background:Rectangle {
        radius: 8
        color: root.bgColor
    }
    contentItem: RowLayout {
        clip: true
        spacing: root.spacing
        StatusIcon {
            icon: "tiny/chevron-down"
            visible: root.type === StatusPickerButton.Type.Down
            Layout.alignment: Qt.AlignVCenter
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
            width: root.icon.width
            height: root.icon.height
        }
        StatusRoundedImage {
            visible: root.asset.name.toString() !== ""
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: root.asset.width
            Layout.preferredHeight: root.asset.height
            image.source: root.asset.name
        }
        StatusBaseText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: root.font.pixelSize
            color: root.contentColor
            text: root.text
            clip: true
            elide: Text.ElideRight
        }
        StatusIcon {
            icon: "tiny/chevron-right"
            visible: root.type === StatusPickerButton.Type.Next
            Layout.alignment: Qt.AlignVCenter
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
            width: root.icon.width
            height: root.icon.height
        }
    }

    // TODO: To remove when switch to Qt 5.15
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.clicked() }
    }
}

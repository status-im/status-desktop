import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

StatusButton {
    id: root

    property color bgColor: Theme.palette.baseColor2
    property color contentColor: Theme.palette.baseColor1
    property int type: StatusPickerButton.PickerType.Next

    /*!
       \qmlproperty StatusAssetSettings StatusPickerButton::asset
       This property holds the image settings information.
    */
    asset {
        width: 20
        height: 20
        imgIsIdenticon: false
    }

    enum PickerType {
        Next,
        Down
    }

    horizontalPadding: 16
    verticalPadding: 3
    spacing: 4
    icon.width: 16
    icon.height: 16
    background: Rectangle {
        radius: 8
        color: root.bgColor
    }
    opacity: !root.interactive || !root.enabled ? 0.5 : 1
    contentItem: RowLayout {
        spacing: root.spacing
        StatusIcon {
            icon: "tiny/chevron-down"
            visible: root.type === StatusPickerButton.PickerType.Down
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
            width: root.icon.width
            height: root.icon.height
        }
        StatusRoundedImage {
            visible: root.asset.name.toString() !== ""
            Layout.preferredWidth: root.asset.width
            Layout.preferredHeight: root.asset.height
            image.source: root.asset.name
        }
        StatusBaseText {
            Layout.fillWidth: true
            font: root.font
            color: root.contentColor
            text: root.text
            elide: Text.ElideRight
        }
        StatusIcon {
            icon: "tiny/chevron-right"
            visible: root.type === StatusPickerButton.PickerType.Next
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
            width: root.icon.width
            height: root.icon.height
        }
    }

    HoverHandler {
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }
}

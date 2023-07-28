import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

StatusListItem {
    id: root

    property bool isInteractive: false
    property bool copyButtonEnabled: false
    property bool moreButtonEnabled: false

    signal buttonClicked()
    signal copyClicked()

    QtObject {
        id: d
        readonly property var timer: Timer {}
    }

    statusListItemTitle.customColor: Theme.palette.baseColor1
    statusListItemTitle.font.pixelSize: 13
    statusListItemTitle.lineHeightMode: Text.FixedHeight
    statusListItemTitle.lineHeight: 18
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.textFormat: Qt.RichText
    statusListItemSubTitle.lineHeightMode: Text.FixedHeight
    statusListItemSubTitle.lineHeight: 22
    statusListItemSubTitle.elide: Text.ElideNone
    statusListItemSubTitle.wrapMode: Text.WrapAnywhere
    color: {
        if (isInteractive && (sensor.containsMouse || root.highlighted)) {
            return Theme.palette.baseColor2
        }
        return Theme.palette.transparent
    }
    components: [
        StatusRoundButton {
            width: 32
            height: 32
            radius: 8
            visible: moreButtonEnabled && isInteractive  && root.sensor.containsMouse
            type: StatusRoundButton.Type.Quinary
            icon.name: "more"
            icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            icon.hoverColor: Theme.palette.primaryColor3
            onClicked: root.buttonClicked()
        },
        StatusRoundButton {
            id: copyButton
            property bool checked: false
            width: 32
            height: 32
            radius: 8
            visible: copyButtonEnabled && isInteractive  && root.sensor.containsMouse
            type: StatusRoundButton.Type.Quinary
            icon.name: copyButton.checked ? "tiny/checkmark": "copy"
            icon.color: copyButton.checked ? Theme.palette.successColor1 : hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            icon.hoverColor: copyButton.checked ? Theme.palette.successColor1 : Theme.palette.primaryColor3
            onClicked: {
                copyButton.checked = true
                root.copyClicked()
                d.timer.setTimeout(function() {
                    copyButton.checked = false
                }, 1500)
            }
        }
    ]
}

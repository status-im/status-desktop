import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

ItemDelegate {
    id: root

    property bool isSwitch: false
    property string currentValue
    property int badgeValue
    property int badgeRadius: 9

    implicitHeight: 64

    horizontalPadding: Theme.padding
    spacing: Theme.padding

    checkable: isSwitch
    hoverEnabled: enabled

    background: Rectangle {
        color: hovered ? Theme.palette.backgroundHover : Theme.palette.transparent
        radius: Theme.radius
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusRoundIcon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            visible: !!root.icon.source.toString()
            asset.source: root.icon.source
            asset.bgColor: Theme.palette.secondaryBackground
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: root.text
            elide: Text.ElideRight
        }

        StatusBaseText {
            visible: !!root.currentValue
            text: root.currentValue
            horizontalAlignment: Text.AlignRight
            color: Theme.palette.secondaryText
        }

        StatusBadge {
            visible: badgeValue > 0
            radius: root.badgeRadius
            color: Theme.palette.primaryColor1
            value: root.badgeValue
        }

        StatusSwitch {
            visible: root.checkable
            checked: root.checked
            onToggled: root.click()
        }

        StatusIcon {
            visible: !root.checkable
            icon: "next"
            color: Theme.palette.secondaryText
        }
    }

    HoverHandler {
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
}

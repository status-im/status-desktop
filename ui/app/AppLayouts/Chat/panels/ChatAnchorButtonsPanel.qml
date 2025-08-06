import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

import utils
import shared

Item {
    id: root

    property int mentionsCount
    property int recentMessagesCount

    property alias recentMessagesButtonVisible: recentMessagesButton.visible

    signal mentionsButtonClicked
    signal recentMessagesButtonClicked

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        function limitNumberTo99(number) {
            return number > 99 ? qsTr("99+") : number
        }
    }

    component AnchorButton: StatusButton {
        Layout.preferredHeight: 38
        radius: 100
        spacing: 2

        icon.width: Theme.primaryTextFontSize + 5
        icon.height: Theme.primaryTextFontSize + 5
        verticalPadding: Theme.halfPadding
        horizontalPadding: Theme.smallPadding
        font.pixelSize: Theme.primaryTextFontSize

        layer.enabled: true
        layer.effect: DropShadow {
            samples: 16
            cached: true
            color: Theme.palette.alphaColor(Theme.palette.directColor1, 0.16)
        }
    }

    RowLayout {
        id: layout

        anchors.fill: parent

        spacing: Theme.smallPadding

        AnchorButton {
            visible: root.mentionsCount > 0
            text: d.limitNumberTo99(root.mentionsCount)
            type: StatusBaseButton.Type.Primary
            textColor: Theme.palette.white
            icon.name: "username"

            onClicked: root.mentionsButtonClicked()
        }

        AnchorButton {
            id: recentMessagesButton

            text: root.recentMessagesCount <= 0 ? "" : d.limitNumberTo99(root.recentMessagesCount)
            normalColor: Theme.palette.baseColor1
            hoverColor: Theme.palette.hoverColor(normalColor)
            textColor: Theme.palette.white
            textPosition: StatusBaseButton.TextPosition.Left
            icon.name: "arrow-down"

            onClicked: root.recentMessagesButtonClicked()
        }
    }
}

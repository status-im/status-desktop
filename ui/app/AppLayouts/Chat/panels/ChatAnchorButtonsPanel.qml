import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0

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
        spacing: 4

        icon.width: Style.current.primaryTextFontSize + 5
        icon.height: Style.current.primaryTextFontSize + 5
        verticalPadding: Style.current.halfPadding
        horizontalPadding: Style.current.smallPadding
        font.pixelSize: Style.current.primaryTextFontSize
    }

    RowLayout {
        id: layout

        anchors.fill: parent

        spacing: Style.current.smallPadding

        AnchorButton {
            visible: mentionsCount > 0
            text: d.limitNumberTo99(mentionsCount)
            type: StatusBaseButton.Type.Primary
            icon.name: "username"

            onClicked: root.mentionsButtonClicked()
        }

        AnchorButton {
            id: recentMessagesButton

            text: recentMessagesCount <= 0 ? "" : d.limitNumberTo99(recentMessagesCount)
            normalColor: Style.current.buttonSecondaryColor
            type: StatusRoundButton.Type.Tertiary
            textPosition: StatusBaseButton.TextPosition.Left
            icon.name: "arrow-down"

            onClicked: root.recentMessagesButtonClicked()
        }
    }
}

import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property alias archiveSupportEnabled: archiveSupportToggle.checked
    property alias requestToJoinEnabled: requestToJoinToggle.checked
    property alias pinMessagesEnabled: pinMessagesToggle.checked

    property alias archiveSupporVisible: archiveSupport.visible

    spacing: 0

    QtObject {
        id: d
        readonly property int optionHeight: 64
    }

    Item {
        id: archiveSupport

        Layout.preferredWidth: parent.width
        Layout.preferredHeight: visible ? d.optionHeight : 0

        StatusCheckBox {
            id: archiveSupportToggle
            width: (parent.width-12)
            checked: false
            leftSide: false
            padding: 0
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Community history service")

            StatusToolTip {
                text: qsTr('For this Community Setting to work, you also need to activate "Archive Protocol Enabled" in Advanced Settings')
                visible: hoverHandler.hovered
            }
            HoverHandler {
                id: hoverHandler
                enabled: true
            }
        }
    }

    Item {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: d.optionHeight

        StatusCheckBox {
            id: pinMessagesToggle
            width: (parent.width-12)
            leftSide: false
            padding: 0
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Any member can pin a message")
        }
    }

    ColumnLayout {
        Layout.preferredWidth: parent.width
        Layout.topMargin: 22
        spacing: 0
        StatusCheckBox {
            id: requestToJoinToggle
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 12
            text: qsTr("Request to join required")
            leftSide: false
            padding: 0
        }

        StatusBaseText {
            id: warningText
            Layout.fillWidth: true
            Layout.rightMargin: 12
            visible: requestToJoinToggle.checked
            wrapMode: Text.WordWrap
            text: qsTr("Warning: Only token gated communities (or token gated channels inside non-token gated community) are encrypted")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.warningColor1
        }
    }
}

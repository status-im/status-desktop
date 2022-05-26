import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property alias archiveSupportOptionVisible: archiveSupport.visible

    property alias archiveSupportEnabled: archiveSupportToggle.checked
    property alias requestToJoinEnabled: requestToJoinToggle.checked
    property alias pinMessagesEnabled: pinMessagesToggle.checked

    spacing: 0

    QtObject {
        id: d
        readonly property real optionHeight: 64
    }

    RowLayout {
        id: archiveSupport

        Layout.fillWidth: true

        StatusBaseText {
            text: qsTr("Community history service")
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: d.optionHeight
        }

        StatusCheckBox {
            id: archiveSupportToggle
        }
    }

    RowLayout {
        Layout.fillWidth: true

        StatusBaseText {
            text: qsTr("Request to join required")
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: d.optionHeight
        }

        StatusCheckBox {
            id: requestToJoinToggle
        }
    }

    RowLayout {
        Layout.fillWidth: true

        StatusBaseText {
            text: qsTr("Any member can pin a message")
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: d.optionHeight
        }

        StatusCheckBox {
            id: pinMessagesToggle
        }
    }
}

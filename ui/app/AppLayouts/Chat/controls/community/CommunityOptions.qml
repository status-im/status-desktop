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
    property alias encrypted: encryptedToggle.checked

    property bool encryptReadOnly: false

    spacing: 0

    QtObject {
        id: d
        readonly property int optionHeight: 64
    }

    RowLayout {
        id: archiveSupport

        Layout.fillWidth: true
        Layout.preferredHeight: d.optionHeight

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Community history service")
            TapHandler {
                onTapped: archiveSupportToggle.toggle()
            }
        }

        StatusCheckBox {
            id: archiveSupportToggle
            checked: true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: d.optionHeight

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Request to join required")
            TapHandler {
                onTapped: requestToJoinToggle.toggle()
            }
        }

        StatusCheckBox {
            id: requestToJoinToggle
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: d.optionHeight

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Any member can pin a message")
            TapHandler {
                onTapped: pinMessagesToggle.toggle()
            }
        }

        StatusCheckBox {
            id: pinMessagesToggle
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: d.optionHeight
        visible: requestToJoinToggle.checked

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Encrypted")
            TapHandler {
                enabled: !encryptReadOnly
                onTapped: encryptedToggle.toggle()
            }
        }

        StatusCheckBox {
            id: encryptedToggle
            enabled: !encryptReadOnly
        }
    }
}

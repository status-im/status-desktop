import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Column {
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

    RowLayout {
        id: archiveSupport

        width: parent.width
        height: visible ? d.optionHeight : 0

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Community history service")
            font.pixelSize: Theme.primaryTextFontSize
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
        width: parent.width
        height: d.optionHeight

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Request to join required")
            font.pixelSize: Theme.primaryTextFontSize
            TapHandler {
                onTapped: requestToJoinToggle.toggle()
            }
        }

        StatusCheckBox {
            id: requestToJoinToggle
        }
    }

    RowLayout {
        width: parent.width
        height: d.optionHeight

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Any member can pin a message")
            font.pixelSize: Theme.primaryTextFontSize
            TapHandler {
                onTapped: pinMessagesToggle.toggle()
            }
        }

        StatusCheckBox {
            id: pinMessagesToggle
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import shared.views
import shared.popups

OnboardingPage {
    id: root

    property var validateConnectionString: (stringValue) => { console.error("validateConnectionString IMPLEMENT ME"); return false }

    signal syncProceedWithConnectionString(string connectionString)

    title: qsTr("Pair devices to sync")

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.topMargin: -Theme.bigPadding
                text: qsTr("If you have Status on another device")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            SyncingEnterCode {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                validateConnectionString: root.validateConnectionString

                onDisplayInstructions: instructionsPopup.createObject(root).open()
                onProceed: (connectionString) => root.syncProceedWithConnectionString(connectionString)
            }
        }
    }

    Component {
        id: instructionsPopup
        GetSyncCodeInstructionsPopup {
            destroyOnClose: true
        }
    }
}

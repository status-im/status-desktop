import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.views 1.0
import shared.popups 1.0

OnboardingPage {
    id: root

    property var validateConnectionString: (stringValue) => { console.error("validateConnectionString IMPLEMENT ME"); return false }

    signal syncProceedWithConnectionString(string connectionString)

    title: qsTr("Pair devices to sync")

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(440, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 22
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

                showBetaTag: false

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

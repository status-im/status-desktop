import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

OnboardingPage {
    id: root

    signal backupSeedphraseRequested()

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(400, root.availableWidth)
            spacing: 20

            StatusImage {
                id: image
                Layout.preferredWidth: 296
                Layout.preferredHeight: 260
                Layout.alignment: Qt.AlignHCenter
                mipmap: true
                source: Theme.png("onboarding/status_seedphrase")
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Backup your recovery phrase")
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Your recovery phrase is a 12 word passcode to your funds that cannot be recovered if lost. Write it down offline and store it somewhere secure.")
            }
            StatusButton {
                objectName: "btnBackupSeedphrase"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Backup recovery phrase")
                onClicked: root.backupSeedphraseRequested()
            }
        }
    }
}

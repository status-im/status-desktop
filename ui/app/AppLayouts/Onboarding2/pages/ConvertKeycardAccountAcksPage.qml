import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

OnboardingPage {
    id: root

    title: qsTr("Are you sure you want to migrate this profile keypair to Status?")

    signal continueRequested()

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(390, root.availableWidth)
            spacing: 20

            StatusRoundIcon {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                asset.name: "warning"
                asset.color: Theme.palette.warningColor1
                asset.bgColor: Theme.palette.warningColor2
            }

            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                text: root.title
                horizontalAlignment: Text.AlignHCenter
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                color: Theme.palette.warningColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("This profile and its accounts will be less secure, as Keycard will no longer be required to transact or login.")
            }

            StatusBaseText {
                id: subtitle
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Your data will also be re-encrypted, restricting access to Status for up to 30 mins. Do you wish to continue?")
            }

            StatusButton {
                objectName: "continueButton"
                text: qsTr("Continue")
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.continueRequested()
            }
        }
    }
}

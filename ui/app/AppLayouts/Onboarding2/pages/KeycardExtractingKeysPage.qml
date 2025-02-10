import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

OnboardingPage {
    id: root

    title: qsTr("Extracting keys from Keycard")

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(350, root.availableWidth)
            spacing: Theme.halfPadding

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter

                color: Theme.palette.baseColor2
                radius: width/2

                StatusDotsLoadingIndicator {
                    anchors.centerIn: parent
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                text: root.title
                horizontalAlignment: Text.AlignHCenter
            }

            StatusBaseText {
                id: subtitle

                Layout.fillWidth: true

                text: qsTr("You will now require this Keycard to log into Status and transact with any accounts derived from this key pair")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusImage {
                id: image

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(231, parent.width)
                Layout.preferredHeight: Math.min(211, height)
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding
                source: Theme.png("onboarding/status_keycard_adding_keypair")
                mipmap: true
            }

            StatusBaseText {
                id: subImageText

                Layout.fillWidth: true

                text: qsTr("Please keep the Keycard plugged in until the extraction is complete")

                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

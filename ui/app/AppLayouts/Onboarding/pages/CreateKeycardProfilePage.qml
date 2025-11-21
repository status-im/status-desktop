import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups

import AppLayouts.Onboarding.controls

OnboardingPage {
    id: root

    title: qsTr("Create profile on empty Keycard")

    signal createKeycardProfileWithNewSeedphrase()
    signal createKeycardProfileWithExistingSeedphrase()

    contentItem: Item {
        ColumnLayout {
            width: parent.width
            anchors.centerIn: parent

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize(22)
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("You will require your Keycard to log in to Status and sign transactions")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout {
                Layout.maximumWidth: Math.min(380, root.availableWidth)
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 56
                spacing: Theme.bigPadding

                OnboardingFrame {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        spacing: 24
                        StatusImage {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Math.min(252, parent.width)
                            Layout.preferredHeight: Math.min(164, height)
                            source: Theme.png("onboarding/status_generate_keycard")
                            mipmap: true
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            text: qsTr("Use a new recovery phrase")
                            font.pixelSize: Theme.secondaryAdditionalTextSize
                            font.bold: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.topMargin: -Theme.padding
                            text: qsTr("To create your Keycard-stored profile ")
                            font.pixelSize: Theme.additionalTextSize
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.palette.baseColor1
                        }
                        StatusButton {
                            objectName: "btnCreateWithEmptySeedphrase"
                            Layout.fillWidth: true
                            text: qsTr("Let's go!")
                            font.pixelSize: Theme.additionalTextSize
                            onClicked: root.createKeycardProfileWithNewSeedphrase()
                        }
                    }
                }

                OnboardingButtonFrame {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        spacing: 0
                        ListItemButton {
                            objectName: "btnCreateWithExistingSeedphrase"
                            Layout.fillWidth: true
                            text: qsTr("Use an existing recovery phrase")
                            subTitle: qsTr("To create your Keycard-stored profile ")
                            icon.source: Theme.png("onboarding/create_profile_seed")
                            onClicked: root.createKeycardProfileWithExistingSeedphrase()
                        }
                    }
                }
            }
        }
    }
}

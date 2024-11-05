import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import AppLayouts.Onboarding2.controls 1.0

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
                font.pixelSize: 22
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
                spacing: 20

                OnboardingFrame {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        spacing: 24
                        StatusImage {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Math.min(268, parent.width)
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
                            Layout.fillWidth: true
                            text: qsTr("Let’s go!")
                            font.pixelSize: Theme.additionalTextSize
                            onClicked: root.createKeycardProfileWithNewSeedphrase()
                        }
                    }
                }

                OnboardingFrame {
                    Layout.fillWidth: true
                    padding: 1
                    dropShadow: false
                    contentItem: ColumnLayout {
                        spacing: 0
                        ListItemButton {
                            Layout.fillWidth: true
                            title: qsTr("Use an existing recovery phrase")
                            subTitle: qsTr("To create your Keycard-stored profile ")
                            asset.name: Theme.png("onboarding/create_profile_seed")
                            onClicked: root.createKeycardProfileWithExistingSeedphrase()
                        }
                    }
                }
            }
        }
    }
}

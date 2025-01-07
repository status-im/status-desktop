import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

OnboardingPage {
    id: root

    title: qsTr("Create your profile")

    signal createProfileWithPasswordRequested()
    signal createProfileWithSeedphraseRequested()
    signal createProfileWithEmptyKeycardRequested()

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(380, root.availableWidth)
            spacing: Theme.bigPadding

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
                Layout.topMargin: -Theme.padding
                text: qsTr("How would you like to start using Status?")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            OnboardingFrame {
                Layout.fillWidth: true
                contentItem: ColumnLayout {
                    spacing: 20
                    StatusImage {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(164, parent.width)
                        Layout.preferredHeight: Math.min(164, height)
                        source: Theme.png("onboarding/status_key")
                        mipmap: true
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("Start fresh")
                        font.pixelSize: Theme.secondaryAdditionalTextSize
                        font.bold: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        Layout.topMargin: -Theme.padding
                        text: qsTr("Create a new profile from scratch")
                        font.pixelSize: Theme.additionalTextSize
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.palette.baseColor1
                    }
                    StatusButton {
                        objectName: "btnCreateWithPassword"
                        Layout.fillWidth: true
                        text: qsTr("Let’s go!")
                        font.pixelSize: Theme.additionalTextSize
                        onClicked: root.createProfileWithPasswordRequested()
                    }
                }
            }

            OnboardingButtonFrame {
                Layout.fillWidth: true
                id: buttonFrame
                contentItem: ColumnLayout {
                    spacing: 0
                    ListItemButton {
                        objectName: "btnCreateWithSeedPhrase"
                        Layout.fillWidth: true
                        text: qsTr("Use a recovery phrase")
                        subTitle: qsTr("If you already have an Ethereum wallet")
                        icon.source: Theme.png("onboarding/create_profile_seed")
                        onClicked: root.createProfileWithSeedphraseRequested()
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: -buttonFrame.padding
                        Layout.rightMargin: -buttonFrame.padding
                        Layout.preferredHeight: 1
                        color: Theme.palette.statusMenu.separatorColor
                    }
                    ListItemButton {
                        objectName: "btnCreateWithEmptyKeycard"
                        Layout.fillWidth: true
                        text: qsTr("Use an empty Keycard")
                        subTitle: qsTr("Store your new profile keys on Keycard")
                        icon.source: Theme.png("onboarding/create_profile_keycard")
                        onClicked: root.createProfileWithEmptyKeycardRequested()
                    }
                }
            }
        }
    }
}

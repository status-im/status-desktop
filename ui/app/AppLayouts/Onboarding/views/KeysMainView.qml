import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0
import "../popups"
import "../controls"

import utils 1.0

OnboardingBasePage {
    id: root

    signal buttonClicked()
    signal keycardLinkClicked()
    signal seedLinkClicked()

    Item {
        id: container
        width: 425
        height: 513
        anchors.centerIn: parent

        Item {
            id: keysImgWrapperItem
            width: 257
            height: 257
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                id: keysImg
                width: 257
                height: 257
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                source: Style.png("onboarding/keys")
                mipmap: true
            }
        }

        StyledText {
            id: txtTitle
            text: qsTr("intro-wizard-title1") // FIXME: translations
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImgWrapperItem.bottom
            anchors.topMargin: Style.current.padding
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc
            height: 44
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle.bottom
            anchors.topMargin: Style.current.padding
            color: Style.current.secondaryText
            text: qsTr("a-set-of-keys-controls-your-account.-your-keys-live-on-your-device,-so-only-you-can-use-them.") // FIXME: translations
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 15
        }

        ColumnLayout {
            anchors.top: txtDesc.bottom
            anchors.topMargin: 32
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.bigPadding
            StatusButton {
                id: button
                enabled: (opacity > 0.1)
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    root.buttonClicked();
                }
            }

            StatusBaseText {
                id: keycardLink
                Layout.alignment: Qt.AlignHCenter
                color: Theme.palette.primaryColor1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        root.keycardLinkClicked();
                    }
                }
            }

            StatusBaseText {
                id: seedLink
                Layout.alignment: Qt.AlignHCenter
                color: Theme.palette.primaryColor1
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        root.seedLinkClicked();
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "connectkeys"
            PropertyChanges {
                target: keysImg
                width: 160
                height: 160
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Connect your keys")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Use your existing Status keys to login to this device.")
            }
            PropertyChanges {
                target: button
//                text: qsTr("Scan sync code")
                //TODO remove when sync code is implemented
                opacity: 0.0
            }
//            PropertyChanges {
//                target: keycardLink
//                text: qsTr("Login with Keycard")
//            }
            PropertyChanges {
                target: seedLink
                text: qsTr("Enter a seed phrase")
            }
        },
        State {
            name: "getkeys"
            PropertyChanges {
                target: keysImg
                width: 160
                height: 160
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Get your keys")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("A set of keys controls your account. Your keys live on your\ndevice, so only you can use them.")
            }
            PropertyChanges {
                target: button
                text: qsTr("Generate new keys")
                //TODO remove when sync code is implemented
                opacity: 1.0
            }
//            PropertyChanges {
//                target: keycardLink
//                text: qsTr("Generate keys for a new Keycard")
//            }
            PropertyChanges {
                target: seedLink
                text: qsTr("Import a seed phrase")
            }
        },
        State {
            name: "importseed"
            PropertyChanges {
                target: keysImg
                width: 257
                height: 257
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Import a seed phrase")
            }
            PropertyChanges {
                target: keysImg
                width: 257
                height: 257
                source: Style.png("onboarding/seed-phrase")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Seed phrases are used to back up and restore your keys. Only use this option if you already have a seed phrase.")

            }
            PropertyChanges {
                target: button
                text: qsTr("Import a seed phrase")
                //TODO remove when sync code is implemented
                opacity: 1.0
            }
//            PropertyChanges {
//                target: keycardLink
//                text: qsTr("Import a seed phrase into a new Keycard")
//            }
            PropertyChanges {
                target: seedLink
                text: ""
                visible: false
            }
        }
    ]
}

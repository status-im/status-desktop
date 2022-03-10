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

import utils 1.0

Page {
    id: root

    signal buttonClicked()
    signal keycardLinkClicked()
    signal seedLinkClicked()
    signal backClicked()

    background: Rectangle {
        color: Style.current.background
    }

    Component.onCompleted: {
        if(displayBeforeGetStartedModal) {
            displayBeforeGetStartedModal = false
            beforeGetStartedModal.open()
        }
    }

    BeforeGetStartedModal {
        id: beforeGetStartedModal
    }

    Item {
        id: container
        width: 425
        height: {
            let h = 0
            const children = this.children
            Object.keys(children).forEach(function (key) {
                const child = children[key]
                h += child.height + Style.current.padding
            })
            return h
        }

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: keysImg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            source: Style.png("keys")
            width: 160
            height: 160
            mipmap: true
        }

        StyledText {
            id: txtTitle
            text: qsTrId("intro-wizard-title1")
            anchors.topMargin: Style.current.padding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc
            color: Style.current.secondaryText
            text: qsTrId("a-set-of-keys-controls-your-account.-your-keys-live-on-your-device,-so-only-you-can-use-them.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle.bottom
            anchors.topMargin: Style.current.padding
            font.pixelSize: 15
        }
        ColumnLayout {
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: txtDesc.bottom
            spacing: Style.current.bigPadding
            StatusButton {
                id: button
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

    StatusRoundButton {
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        icon.name: "arrow-left"
        onClicked: {
            root.backClicked();
        }
    }

    states: [
        State {
            name: "connectkeys"
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
                text: qsTr("Scan sync code")

            }
            PropertyChanges {
                target: keycardLink
                text: qsTr("Login with Keycard")

            }
            PropertyChanges {
                target: seedLink
                text: qsTr("Enter a seed phrase")

            }
        },
        State {
            name: "getkeys"
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

            }
            PropertyChanges {
                target: keycardLink
                text: qsTr("Generate keys for a new Keycard")

            }
            PropertyChanges {
                target: seedLink
                text: qsTr("lmport a seed phrase")

            }
        },
        State {
            name: "importseed"
            PropertyChanges {
                target: txtTitle
                text: qsTr("lmport a seed phrase")

            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Seed phrases are used to back up and restore your keys.\n
Only use this option if you already have a seed phrase.")

            }
            PropertyChanges {
                target: button
                text: qsTr("lmport a seed phrase")

            }
            PropertyChanges {
                target: keycardLink
                text: qsTr("lmport a seed phrase into a new Keycard")

            }
            PropertyChanges {
                target: seedLink
                text: ""
                visible: false
            }
        }
    ]
}

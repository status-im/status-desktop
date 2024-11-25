import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0

import "../popups"
import "../controls"
import "../stores"

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        if (button1.visible) {
            button1.forceActiveFocus()
        }
    }

    QtObject {
        id: d
        readonly property int infoWidth: 292
        readonly property int infoHeight: 309
        readonly property int infoMargin: 24
        readonly property int infoTextWidth: d.infoWidth - 2 * d.infoMargin
        readonly property int imgKeysWH: 160
        readonly property int imgSeedPhraseWH: 257
    }

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.onboarding.loginHeight
        spacing: Theme.bigPadding

        Image {
            id: keysImg
            Layout.alignment: Qt.AlignHCenter
            mipmap: true
            cache: false
        }

        StyledText {
            id: txtTitle
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
            font.letterSpacing: -0.2
            font.pixelSize: Constants.onboarding.fontSize1
        }

        StyledText {
            id: txtDesc
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.secondaryText
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Constants.onboarding.fontSize3
        }

        Item {
            id: spacer
            Layout.preferredHeight: Theme.padding
            Layout.preferredWidth: 1
        }

        Row {
            id: whatYouLoseGet
            visible: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreateSameChatKey
            spacing: Theme.bigPadding
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                width: d.infoWidth
                height: d.infoHeight
                radius: Constants.onboarding.radius
                color: Theme.palette.baseColor5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: d.infoMargin
                    spacing: Theme.bigPadding

                    RowLayout {
                        StyledText {
                            text: qsTr("What you lose")
                            font.pixelSize: Constants.onboarding.fontSize2
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }
                        StatusEmoji {
                            width: 24
                            height: 24
                            emojiId: "1f622"
                        }
                    }

                    ColumnLayout {
                        StyledText {
                            text: qsTr("Chat history")
                            font.pixelSize: Constants.onboarding.fontSize3
                            font.bold: true
                        }

                        StyledText {
                            Layout.preferredWidth: d.infoTextWidth
                            text: qsTr("Past is in the past. Move on :)")
                            font.pixelSize: Constants.onboarding.fontSize3
                            wrapMode: Text.WordWrap
                        }
                    }

                    ColumnLayout {
                        StyledText {
                            text: qsTr("Contacts")
                            font.pixelSize: Constants.onboarding.fontSize3
                            font.bold: true
                        }

                        StyledText {
                            Layout.preferredWidth: d.infoTextWidth
                            text: qsTr("You can add them back to your contact list")
                            font.pixelSize: Constants.onboarding.fontSize3
                            wrapMode: Text.WordWrap
                        }
                    }

                    ColumnLayout {
                        StyledText {
                            text: qsTr("Community memberships")
                            font.pixelSize: Constants.onboarding.fontSize3
                            font.bold: true
                        }

                        StyledText {
                            Layout.preferredWidth: d.infoTextWidth
                            text: qsTr("You’ll need to rejoin communities")
                            font.pixelSize: Constants.onboarding.fontSize3
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            Rectangle {
                width: d.infoWidth
                height: d.infoHeight
                radius: Constants.onboarding.radius
                color: Theme.palette.baseColor5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: d.infoMargin
                    spacing: Theme.bigPadding

                    RowLayout {
                        StyledText {
                            text: qsTr("What you keep")
                            font.pixelSize: Constants.onboarding.fontSize2
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }
                        StatusEmoji {
                            width: 24
                            height: 24
                            emojiId: "1f389"
                        }
                    }

                    ColumnLayout {
                        StyledText {
                            text: qsTr("Chatkey")
                            font.pixelSize: Constants.onboarding.fontSize3
                            font.bold: true
                        }

                        StyledText {
                            Layout.preferredWidth: d.infoTextWidth
                            text: qsTr("Your contacts can still reach you just like before")
                            font.pixelSize: Constants.onboarding.fontSize3
                            wrapMode: Text.WordWrap
                        }
                    }

                    ColumnLayout {
                        StyledText {
                            text: qsTr("Wallet accounts")
                            font.pixelSize: Constants.onboarding.fontSize3
                            font.bold: true
                        }

                        StyledText {
                            Layout.preferredWidth: d.infoTextWidth
                            text: qsTr("All your assets and collectibles are safe in your accounts")
                            font.pixelSize: Constants.onboarding.fontSize3
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        StatusButton {
            id: button1
            objectName: "keysMainViewPrimaryActionButton"
            Layout.alignment: Qt.AlignHCenter
            visible: text !== ""
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true
                    root.startupStore.doPrimaryAction()
                }
            }

            StatusBetaTag {
                id: betaTagButton1
                visible: true
                anchors.left: button1.right
                anchors.leftMargin: 8
                anchors.verticalCenter: button1.verticalCenter
            }
        }

        StatusBaseText {
            id: button2
            objectName: "iDontHaveOtherDeviceButton"
            Layout.alignment: Qt.AlignHCenter
            visible: text !== ""
            color: Theme.palette.primaryColor1
            font.pixelSize: Constants.onboarding.fontSize3
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
                    root.startupStore.doSecondaryAction()
                }
            }
        }

        Row {
            id: button3

            property string text: ""
            property string link: ""
            property bool useLinkForButton: false

            Layout.alignment: Qt.AlignHCenter
            visible: button3.text !== ""
            spacing: 0
            padding: 0

            StatusBaseText {
                text: button3.text
                color: Theme.palette.primaryColor1
                font.pixelSize: Constants.onboarding.fontSize3
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
                        if (button3.useLinkForButton) {
                            Qt.openUrlExternally(button3.link)
                            return
                        }
                        root.startupStore.doTertiaryAction()
                    }
                }
            }

            StatusFlatRoundButton {
                visible: button3.link !== ""
                height: 20
                width: 20
                icon.name: "external"
                icon.width: 16
                icon.height: 16
                onClicked: {
                    Qt.openUrlExternally(button3.link)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.startupState.welcomeOldStatusUser
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeOldStatusUser
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: d.imgKeysWH
                Layout.preferredHeight: d.imgKeysWH
                source: Theme.png("onboarding/keys")
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Sign in by syncing")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Get your data straight from your other device.")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: qsTr("Scan or enter a sync code")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: true
            }
            PropertyChanges {
                target: button2
                text: qsTr("I don’t have other device")
            }
            PropertyChanges {
                target: button3
                text: ""
            }
        },
        State {
            name: Constants.startupState.recoverOldUser
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.recoverOldUser
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: d.imgKeysWH
                Layout.preferredHeight: d.imgKeysWH
                source: Theme.png("onboarding/keys")
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Connect your keys")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Use your existing Status keys to login to this device.")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: ""
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: qsTr("Login with Keycard")
            }
            PropertyChanges {
                target: button3
                text: qsTr("Enter a recovery phrase")
            }
        },
        State {
            name: Constants.startupState.welcomeNewStatusUser
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeNewStatusUser
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: d.imgKeysWH
                Layout.preferredHeight: d.imgKeysWH
                source: Theme.png("onboarding/keys")
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Get your keys")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("A set of keys controls your account. Your keys live on your\ndevice, so only you can use them.")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: qsTr("Generate new keys")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: qsTr("Generate keys for a new Keycard")
            }
            PropertyChanges {
                target: button3
                text: qsTr("Import a recovery phrase")
            }
        },
        State {
            name: Constants.startupState.userProfileImportSeedPhrase
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileImportSeedPhrase
            PropertyChanges {
                target: txtTitle
                text: qsTr("Import a recovery phrase")
            }
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: d.imgSeedPhraseWH
                Layout.preferredHeight: d.imgSeedPhraseWH
                source: Theme.png("onboarding/seed-phrase")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Recovery phrases are used to back up and restore your keys.\nOnly use this option if you already have a recovery phrase.")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: qsTr("Import a recovery phrase")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: qsTr("Import a recovery phrase into a new Keycard")
            }
            PropertyChanges {
                target: button3
                text: ""
            }
        },
        State {
            name: Constants.startupState.profileFetchingAnnouncement
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetchingAnnouncement
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: d.imgKeysWH
                Layout.preferredHeight: d.imgKeysWH
                source: Theme.png("onboarding/keys")
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Unable to fetch your profile")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("We cannot retrieve your profile data. If you have another device\nwith the Status profile, make sure that Status is running on the\nother device and that both devices are online.")
                height: Constants.onboarding.loginInfoHeight3
            }
            PropertyChanges {
                target: button1
                text: qsTr("Try to fetch profile again")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: qsTr("Create new profile with the same chatkey")
            }
            PropertyChanges {
                target: button3
                text: ""
            }
        },
        State {
            name: Constants.startupState.userProfileCreateSameChatKey
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreateSameChatKey
            PropertyChanges {
                target: keysImg
                visible: false
            }
            PropertyChanges {
                target: txtTitle
                text: qsTr("Create a new profile with the same chatkey")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("We cannot fetch your profile data, but you still can create a profile with a same\nchatkey, name and avatar so you contacts will be able to reach you. ")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: qsTr("Continue")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: ""
            }
            PropertyChanges {
                target: button3
                text: ""
            }
        },
        State {
            name: Constants.startupState.lostKeycardOptions
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.lostKeycardOptions
            PropertyChanges {
                target: keysImg
                Layout.preferredWidth: Constants.keycard.general.imageWidth
                Layout.preferredHeight: Constants.keycard.general.imageHeight
                source: Theme.png("keycard/keycard-new")
            }
            PropertyChanges {
                target: txtTitle
                text: ""
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Sorry to hear you’ve lost your Keycard, you have 3 options")
                height: Constants.onboarding.loginInfoHeight2
            }
            PropertyChanges {
                target: button1
                text: qsTr("Create replacement Keycard with recovery phrase")
            }
            PropertyChanges {
                target: betaTagButton1
                visible: false
            }
            PropertyChanges {
                target: button2
                text: qsTr("Start using account without keycard")
            }
            PropertyChanges {
                target: button3
                text: qsTr("Order new keycard")
                link: "https://get.keycard.tech"
                useLinkForButton: true
            }
        }
    ]
}

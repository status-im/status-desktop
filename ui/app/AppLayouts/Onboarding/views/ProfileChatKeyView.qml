import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import shared.panels 1.0
import shared 1.0
import shared.popups 1.0
import shared.controls 1.0
import utils 1.0

import "../popups"
import "../stores"
import "../shared"

Item {
    id: root
    objectName: "onboardingProfileChatKeyView"

    property StartupStore startupStore

    Component.onCompleted: {
        nextBtn.forceActiveFocus()
    }

    QtObject {
        id: d

        property string publicKey: root.startupStore.startupModuleInst.loggedInAccountPublicKey
        property string displayName: root.startupStore.startupModuleInst.loggedInAccountDisplayName
        property string image: root.startupStore.startupModuleInst.loggedInAccountImage

        function doAction() {
            if (!nextBtn.enabled) {
                return
            }
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        height: 461
        anchors.centerIn: parent

        StyledText {
            id: usernameText
            objectName: "onboardingHeaderText"
            text: qsTr("Your emojihash and identicon ring")
            font.weight: Font.Bold
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            id: txtDesc
            Layout.preferredWidth: root.state === Constants.startupState.userProfileCreate? 338 : 643
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Style.current.smallPadding
            color: Style.current.secondaryText
            text: qsTr("This set of emojis and coloured ring around your avatar are unique and represent your chat key, so your friends can easily distinguish you from potential impersonators.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            lineHeight: 1.2
            font.letterSpacing: -0.2
        }

        Item {
            Layout.preferredWidth: 86
            Layout.preferredHeight: 86
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Style.current.bigPadding
            StatusSmartIdenticon {
                id: userImage
                objectName: "welcomeScreenUserProfileImage"
                anchors.left: parent.left
                asset.width: 86
                asset.height: 86
                asset.letterSize: 32
                asset.color: Utils.colorForPubkey(d.publicKey)
                asset.charactersLen: 2
                asset.isImage: !!asset.name
                asset.imgIsIdenticon: false
                asset.name: d.image
                name: d.displayName
                ringSettings {
                    ringSpecModel: Utils.getColorHashAsJson(d.publicKey)
                }
            }
        }

        StyledText {
            id: chatKeyTxt
            objectName: "profileChatKeyViewChatKeyTxt"
            Layout.preferredHeight: 22
            color: Style.current.secondaryText
            text: qsTr("Chatkey:") + " " + Utils.getCompressedPk(d.publicKey)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 13
            font.pixelSize: 15
            visible: true
        }

        Item {
            id: chainsChatKeyImg
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: Style.current.padding
            Layout.preferredWidth: 215
            Layout.preferredHeight: 77

            Image {
                id: imgChains
                anchors.horizontalCenter: parent.horizontalCenter
                source: Style.svg("onboarding/chains")
                cache: false
            }
            EmojiHash {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                publicKey: d.publicKey
                objectName: "publicKeyEmojiHash"
            }
            StatusSmartIdenticon {
                id: userImageCopy
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: 25
                }
                asset.width: 44
                asset.height: 44
                asset.color: "transparent"
                ringSettings { ringSpecModel: Utils.getColorHashAsJson(d.publicKey) }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusButton {
            id: nextBtn
            objectName: "onboardingDetailsViewNextButton"
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Medium
            text: root.startupStore.notificationsNeedsEnable ? qsTr("Next") : qsTr("Start using Status")
            onClicked: {
                d.doAction()
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true
                    d.doAction()
                }
            }
        }
    }
}

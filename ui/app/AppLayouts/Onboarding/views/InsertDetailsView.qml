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
    objectName: "onboardingInsertDetailsView"
    property StartupStore startupStore

    property string pubKey
    property string address
    property string displayName
    signal createPassword()

    Component.onCompleted: {
        if (!!root.startupStore.startupModuleInst.importedAccountPubKey) {
            root.address = root.startupStore.startupModuleInst.importedAccountAddress ;
            root.pubKey = root.startupStore.startupModuleInst.importedAccountPubKey;
        }
        nameInput.text = root.startupStore.getDisplayName();
        userImage.asset.name = root.startupStore.getCroppedProfileImage();
    }

    onStateChanged: {
        if (state === Constants.startupState.userProfileCreate) {
            nameInput.input.edit.forceActiveFocus()
            return
        }
        nextBtn.forceActiveFocus()
    }

    Loader {
        active: !root.startupStore.startupModuleInst.importedAccountPubKey
        sourceComponent: StatusListView {
            model: root.startupStore.startupModuleInst.generatedAccountsModel
            delegate: Item {
                Component.onCompleted: {
                    if (index === 0) {
                        root.address = model.address;
                        root.pubKey = model.pubKey;
                    }
                }
            }
        }
    }

    QtObject {
        id: d

        function doAction() {
            if(!nextBtn.enabled) {
                return
            }
            if (root.state === Constants.startupState.userProfileCreate) {
                root.startupStore.setDisplayName(nameInput.text)
                root.displayName = nameInput.text;
            }
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        height: 461
        anchors.centerIn: parent

        StyledText {
            id: usernameText
            text: qsTr("Your profile")
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
            text: qsTr("Longer and unusual names are better as they are less likely to be used by someone else.")
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
                anchors.left: parent.left
                id: userImage
                objectName: "welcomeScreenUserProfileImage"
                asset.width: 86
                asset.height: 86
                asset.letterSize: 32
                asset.color: Utils.colorForPubkey(root.pubKey)
                asset.charactersLen: 2
                asset.isImage: !!asset.name
                asset.imgIsIdenticon: false
                ringSettings {
                    ringSpecModel: Utils.getColorHashAsJson(root.pubKey)
                }
            }
            StatusRoundButton {
                id: updatePicButton
                width: 40
                height: 40
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: -20
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "add"
                onClicked: {
                    cropperModal.chooseImageToCrop();
                }
            }
        }

        Item {
            id: nameInputItem
            Layout.preferredWidth: 328
            Layout.preferredHeight: 66
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 37
            StatusInput {
                id: nameInput
                input.edit.objectName: "onboardingDisplayNameInput"
                width: parent.width
                placeholderText: qsTr("Display name")
                input.clearable: true
                errorMessageCmp.wrapMode: Text.NoWrap
                errorMessageCmp.horizontalAlignment: Text.AlignHCenter
                validators: Constants.validators.displayName
                onTextChanged: {
                    userImage.name = text;
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true
                        d.doAction()
                    }
                }
            }
        }

        StyledText {
            id: chatKeyTxt
            objectName: "insertDetailsViewChatKeyTxt"
            Layout.preferredHeight: 22
            color: Style.current.secondaryText
            text: qsTr("Chatkey:") + " " + Utils.getCompressedPk(root.pubKey)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 13
            font.pixelSize: 15
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
                publicKey: root.pubKey
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
                ringSettings { ringSpecModel: Utils.getColorHashAsJson(root.pubKey) }
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
            enabled: !!nameInput.text && nameInput.valid
            font.weight: Font.Medium
            text: qsTr("Next")
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

        ImageCropWorkflow {
            id: cropperModal
            imageFileDialogTitle: qsTr("Choose an image for profile picture")
            title: qsTr("Profile picture")
            acceptButtonText: qsTr("Make this my profile picture")
            onImageCropped: {
                const croppedImg = root.startupStore.generateImage(image,
                                                                 cropRect.x.toFixed(),
                                                                 cropRect.y.toFixed(),
                                                                 (cropRect.x + cropRect.width).toFixed(),
                                                                 (cropRect.y + cropRect.height).toFixed());
                userImage.asset.name = croppedImg;
            }
        }
    }

    states: [
        State {
            name: Constants.startupState.userProfileCreate
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreate
            PropertyChanges {
                target: usernameText
                text: qsTr("Your profile")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("Longer and unusual names are better as they are less likely to be used by someone else.")
            }
            PropertyChanges {
                target: chatKeyTxt
                visible: false
            }
            PropertyChanges {
                target: chainsChatKeyImg
                opacity: 0.0
            }
            PropertyChanges {
                target: userImageCopy
                opacity: 0.0
            }
            PropertyChanges {
                target: updatePicButton
                opacity: 1.0
            }
            PropertyChanges {
                target: nameInputItem
                enabled: true
                visible: true
            }
        },
        State {
            name: Constants.startupState.userProfileChatKey
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileChatKey
            PropertyChanges {
                target: usernameText
                text: qsTr("Your emojihash and identicon ring")
            }
            PropertyChanges {
                target: txtDesc
                text: qsTr("This set of emojis and coloured ring around your avatar are unique and represent your chat key, so your friends can easily distinguish you from potential impersonators.")
            }
            PropertyChanges {
                target: chatKeyTxt
                visible: true
            }
            PropertyChanges {
                target: chainsChatKeyImg
                opacity: 1.0
            }
            PropertyChanges {
                target: userImageCopy
                opacity: 1.0
            }
            PropertyChanges {
                target: updatePicButton
                opacity: 0.0
            }
            PropertyChanges {
                target: nameInputItem
                enabled: false
                visible: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            SequentialAnimation {
                PropertyAction {
                    target: root
                    property: "opacity"
                    value: 0.0
                }
                PropertyAction {
                    target: root
                    property: "opacity"
                    value: 1.0
                }
            }
        }
    ]
}

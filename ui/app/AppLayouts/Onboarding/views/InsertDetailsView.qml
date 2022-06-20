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

import utils 1.0
import shared.controls 1.0
import "../popups"
import "../stores"
import "../shared"

Item {
    id: root

    property string pubKey
    property string address
    property string displayName
    signal createPassword()

    state: "username"

    Component.onCompleted: {
        if (!!OnboardingStore.onboardingModuleInst.importedAccountPubKey) {
            root.address = OnboardingStore.onboardingModuleInst.importedAccountAddress ;
            root.pubKey = OnboardingStore.onboardingModuleInst.importedAccountPubKey;
        }
        nameInput.input.edit.forceActiveFocus();
    }

    Loader {
        active: !OnboardingStore.onboardingModuleInst.importedAccountPubKey
        sourceComponent: ListView {
            model: OnboardingStore.onboardingModuleInst.accountsModel
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

    ColumnLayout {
        height: Style.dp(461)
        anchors.centerIn: parent

        StyledText {
            id: usernameText
            text: qsTr("Your profile")
            font.weight: Font.Bold
            font.pixelSize: Style.dp(22)
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            id: txtDesc
            Layout.preferredWidth: (root.state === "username") ? 338 : 643
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Style.current.padding
            color: Style.current.secondaryText
            text: qsTr("Longer and unusual names are better as they are less likely to be used by someone else.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.primaryTextFontSize
        }

        Item {
            implicitWidth: Style.dp(80)
            implicitHeight: Style.dp(80)
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: Style.dp(27)
            StatusSmartIdenticon {
                anchors.left: parent.left
                id: userImage
                image {
                    width: Style.dp(86)
                    height: Style.dp(86)
                    isIdenticon: false
                }
                icon {
                    width: Style.dp(86)
                    height: Style.dp(86)
                    letterSize: Style.dp(32)
                    color: Theme.palette.miscColor5
                    charactersLen: 2
                }
                ringSettings {
                    ringSpecModel: Utils.getColorHashAsJson(root.pubKey)
                }
            }
            StatusRoundButton {
                id: updatePicButton
                width: Style.dp(40)
                height: Style.dp(40)
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: -Style.dp(20)
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "add"
                onClicked: {
                    cropperModal.chooseImageToCrop();
                }
            }
        }

        Item {
            id: nameInputItem
            implicitWidth: Style.dp(328)
            Layout.preferredHeight: Style.dp(69)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: Style.dp(37)
            StatusInput {
                id: nameInput
                width: parent.width
                input.placeholderText: qsTr("Display name")
                input.rightComponent: RoundedIcon {
                    width: Style.dp(14)
                    height: Style.dp(14)
                    iconWidth: Style.dp(14)
                    iconHeight: Style.dp(14)
                    visible: (nameInput.input.text.length > 0)
                    color: "transparent"
                    source: Style.svg("close-filled")
                    onClicked: {
                        nameInput.input.edit.clear();
                    }
                }
                errorMessageCmp.wrapMode: Text.NoWrap
                errorMessageCmp.horizontalAlignment: Text.AlignHCenter
                validators: Constants.validators.displayName
                onTextChanged: {
                    userImage.name = text;
                }
                input.acceptReturn: true
                onKeyPressed: {
                    if (input.edit.keyEvent === Qt.Key_Return || input.edit.keyEvent === Qt.Key_Enter) {
                        event.accepted = true
                        if(nextBtn.enabled) {
                            nextBtn.clicked(null)
                        }
                    }
                }
            }
        }

        StyledText {
            id: chatKeyTxt
            Layout.preferredHeight: Style.dp(44)
            color: Style.current.secondaryText
            text: qsTr("Chatkey:") + " " + Utils.getCompressedPk(root.pubKey)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: Style.dp(13)
            font.pixelSize: Style.current.primaryTextFontSize
        }

        Item {
            id: chainsChatKeyImg
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.padding
            Layout.preferredWidth: Style.dp(215)
            Layout.preferredHeight: Style.dp(77)
            Image {
                id: imgChains
                anchors.horizontalCenter: parent.horizontalCenter
                source: Style.svg("onboarding/chains")
            }
            EmojiHash {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                publicKey: root.pubKey
            }
            StatusSmartIdenticon {
                id: userImageCopy
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: 25
                }
                icon.width: Style.dp(44)
                icon.height: Style.dp(44)
                icon.color: "transparent"
                ringSettings { ringSpecModel: Utils.getColorHashAsJson(root.pubKey) }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusButton {
            id: nextBtn
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            enabled: !!nameInput.text && nameInput.valid
            text: qsTr("Next")
            onClicked: {
                if (root.state === "username") {
                    if (OnboardingStore.accountCreated) {
                        OnboardingStore.updatedDisplayName(nameInput.text);
                    }
                    OnboardingStore.displayName = nameInput.text;
                    root.displayName = nameInput.text;
                    root.state = "chatkey";
                } else {
                    createPassword();
                }
            }
        }

        ImageCropWorkflow {
            id: cropperModal
            imageFileDialogTitle: qsTr("Choose an image for profile picture")
            title: qsTr("Profile picture")
            acceptButtonText: qsTr("Make this my profile picture")
            onImageCropped: {
                const croppedImg = OnboardingStore.generateImage(image,
                                                                 cropRect.x.toFixed(),
                                                                 cropRect.y.toFixed(),
                                                                 (cropRect.x + cropRect.width).toFixed(),
                                                                 (cropRect.y + cropRect.height).toFixed());
                userImage.image.source = croppedImg;
            }
        }
    }

    states: [
        State {
            name: "username"
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
                visible: true
            }
        },
        State {
            name: "chatkey"
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

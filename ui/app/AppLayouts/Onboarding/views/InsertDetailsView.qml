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

    Component.onCompleted: {
        nameInput.text = root.startupStore.getDisplayName();
        userImage.asset.name = root.startupStore.getCroppedProfileImage();
        nameInput.input.edit.forceActiveFocus()
    }

    QtObject {
        id: d

        function doAction() {
            if (!nextBtn.enabled) {
                return
            }
            root.startupStore.setDisplayName(nameInput.text)
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        height: 461
        anchors.centerIn: parent

        StyledText {
            id: usernameText
            objectName: "onboardingHeaderText"
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
                id: userImage
                objectName: "welcomeScreenUserProfileImage"
                anchors.left: parent.left
                asset.width: 86
                asset.height: 86
                asset.letterSize: 32
                asset.color: Utils.colorForColorId(0) // We haven't generated the keys yet, show default color
                asset.charactersLen: 2
                asset.isImage: !!asset.name
                asset.imgIsIdenticon: false
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
            objectName: "imageCropWorkflow"
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
}

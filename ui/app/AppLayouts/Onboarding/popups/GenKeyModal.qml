import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../panels"1
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property int selectedIndex: 0
    property var onClosed: function () {}
    property var onNextClick: function () {}
    id: popup
    //% "Choose a chat name"
    title: qsTrId("intro-wizard-title2")
    height: 504

    property string displayNameValidationError: ""

    Input {
        id: displayNameInput
        placeholderText: "DisplayName"
        validationError: displayNameValidationError
        maxLength: 24
        onTextChanged: {
            let trimmedText = displayNameInput.text.trim()
            if(displayNameInput.text === ""){
                displayNameValidationError = qsTr("Display name is required")
            } else if (!trimmedText.match(/^[a-zA-Z0-9\- ]+$/)){
                displayNameValidationError = qsTr("Only letters, numbers, underscores and hyphens allowed")
            } else if (trimmedText.length > 24) {
                displayNameValidationError = qsTr("24 character username limit")
            } else if (trimmedText.length < 5) {
                displayNameValidationError = qsTr("Username must be at least 5 characters")
            } else if (trimmedText.endsWith(".eth")) {
                displayNameValidationError = qsTr(`Usernames ending with ".eth" are not allowed`)
            } else if (trimmedText.endsWith("-eth")) {
                displayNameValidationError = qsTr(`Usernames ending with "-eth" are not allowed`)
            } else if (trimmedText.endsWith("_eth")) {
                displayNameValidationError = qsTr(`Usernames ending with "_eth" are not allowed`)
            } else if (globalUtils.isAlias(trimmedText)){
                displayNameValidationError = qsTr("Sorry, the name you have chosen is not allowed, try picking another username")
            } else {
                displayNameValidationError = ""
            }
        }
    }

    AccountListPanel {
        id: accountList
        anchors.top: displayNameInput.bottom
        anchors.topMargin: 100
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        interactive: false

        model: OnboardingStore.onBoardingModul.accountsModel
        isSelected: function (index) {
            return index === selectedIndex
        }
        onAccountSelect: function(index) {
            selectedIndex = index
        }
    }

    footer: StatusRoundButton {
        objectName: "submitButton"
        id: submitBtn
        enabled: displayNameInput.text.trim() !== "" && displayNameInput.text.trim().length >= 5
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        onClicked : {
            onNextClick(selectedIndex, displayNameInput.text.trim());
            popup.close()
        }
    }
}

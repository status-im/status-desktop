import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import shared.panels 1.0
import shared.controls 1.0
import shared.stores 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
Column {
    id: root

    property bool ready: newPswInput.text.length >= root.minPswLen && newPswInput.text === confirmPswInput.text && errorTxt.text === ""
    property int minPswLen: 10
    property bool createNewPsw: true
    property string title: qsTr("Create a password")
    property bool titleVisible: true
    property string introText: qsTr("Create a password to unlock Status on this device & sign transactions.")
    property string recoverText: qsTr("You will not be able to recover this password if it is lost.")
    property string strengthenText: qsTr("Minimum %1 characters. To strengthen your password consider including:").arg(minPswLen)
    property bool onboarding: false

    readonly property int zBehind: 1
    readonly property int zFront: 100

    property alias currentPswText: currentPswInput.text
    property alias newPswText: newPswInput.text
    property alias confirmationPswText: confirmPswInput.text
    property alias errorMsgText: errorTxt.text

    signal returnPressed()

    function forceNewPswInputFocus() { newPswInput.forceActiveFocus(Qt.MouseFocusReason) }

    function reset() {
        newPswInput.text = ""
        currentPswInput.text = ""
        confirmPswInput.text = ""
        errorTxt.text = ""
        strengthInditactor.strength = StatusPasswordStrengthIndicator.Strength.None

        // Update focus:
        if(root.createNewPsw)
            newPswInput.forceActiveFocus(Qt.MouseFocusReason)
        else
            currentPswInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function checkPasswordMatches(onlyIfConfirmPasswordHasFocus = true) {
        if (confirmPswInput.textField.text.length === 0) {
            errorTxt.text = ""
            return
        }

        if (onlyIfConfirmPasswordHasFocus && !confirmPswInput.textField.focus) {
            return
        }

        if(newPswInput.text.length >= root.minPswLen) {
            errorTxt.text = ""
            if(confirmPswInput.text !== newPswInput.text) {
                errorTxt.text = qsTr("Passwords don't match")
            }
        }
    }

    QtObject {
        id: d

        property bool containsLower: false
        property bool containsUpper: false
        property bool containsNumbers: false
        property bool containsSymbols: false

        readonly property var validator: RegExpValidator { regExp: /^[!-~]{0,64}$/ } // That incudes NOT extended ASCII printable characters less space and a maximum of 64 characters allowed

        // Password strength categorization / validation
        function lowerCaseValidator(text) { return (/[a-z]/.test(text)) }
        function upperCaseValidator(text) { return (/[A-Z]/.test(text)) }
        function numbersValidator(text) { return (/\d/.test(text)) }
        // That incudes NOT extended ASCII printable symbols less space:
        function symbolsValidator(text) { return (/[!-\/:-@[-`{-~]/.test(text)) }

        // Used to convert strength from a given score to a specific category
        function convertStrength(score) {
            var strength = StatusPasswordStrengthIndicator.Strength.None
            switch(score) {
            case 0: strength = StatusPasswordStrengthIndicator.Strength.VeryWeak; break
            case 1: strength = StatusPasswordStrengthIndicator.Strength.Weak; break
            case 2: strength = StatusPasswordStrengthIndicator.Strength.SoSo; break
            case 3: strength = StatusPasswordStrengthIndicator.Strength.Good; break
            case 4: strength = StatusPasswordStrengthIndicator.Strength.Great; break
            }
            if(strength > 4)
                strength = StatusPasswordStrengthIndicator.Strength.Great
            return strength
        }

        // Password validation / error message selection:
        function passwordValidation() {
            errorTxt.text = ""

            // 3 rules to validate:
            // * Password is in pwnd passwords database
            if(isInPwndDatabase())
                errorTxt.text = qsTr("This password has been pwned and shouldn't be used")

            // * Common password
            else if(isCommonPassword())
                errorTxt.text = qsTr("This password is a common word and shouldn't be used")

            // * Password too short
            else if(isTooShort())
                errorTxt.text = qsTr("Password must be at least %1 characters long").arg(root.minPswLen)
        }

        function isInPwndDatabase() {
            // "TODO - Nice To Have: Pwnd password validation NOT implemented yet! "
            return false
        }

        function isCommonPassword() {
            // "TODO - Nice To Have: Common password validation NOT implemented yet! "
            return false
        }

        function isTooShort() { return newPswInput.text.length < root.minPswLen }
    }

    spacing: 3 * Style.current.padding / 2
    z: root.zFront
    width: Style.dp(416)

    // View visual content:
    StatusBaseText {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.titleVisible
        text: root.title
        font.pixelSize: Style.dp(22)
        font.bold: true
        color: Theme.palette.directColor1
    }

    Column {
        StatusBaseText {
            id: introTxt
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.introText
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            id: recoverTxt
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.recoverText
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
        }
    }

    // TODO replace with StatusInput as soon as it supports password
    Input {
        id: currentPswInput

        property bool showPassword

        z: root.zFront
        visible: !root.createNewPsw
        width: parent.width
        placeholderText: qsTr("Current password")
        textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
        textField.validator: d.validator
        keepHeight: true
        textField.rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2
        Keys.onReturnPressed: { root.returnPressed() }

        StatusFlatRoundButton {
            id: showHideCurrentIcon
            visible: currentPswInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            width: Style.dp(24)
            height: Style.dp(24)
            icon.name: currentPswInput.showPassword ? "hide" : "show"
            icon.color: Theme.palette.baseColor1

            onClicked: currentPswInput.showPassword = !currentPswInput.showPassword
        }
    }

    Column {
        spacing: Style.current.padding / 2
        z: root.zFront
        width: parent.width

        // TODO replace with StatusInput as soon as it supports password
        Input {
            id: newPswInput

            property bool showPassword

            width: parent.width
            placeholderText: qsTr("New password")
            textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
            textField.validator: d.validator
            keepHeight: true
            textField.rightPadding: showHideNewIcon.width + showHideNewIcon.anchors.rightMargin + Style.current.padding / 2

            onTextChanged: {
                // Update password checkers
                d.containsLower = d.lowerCaseValidator(text)
                d.containsUpper = d.upperCaseValidator(text)
                d.containsNumbers = d.numbersValidator(text)
                d.containsSymbols = d.symbolsValidator(text)

                // Update strength indicator:
                strengthInditactor.strength = d.convertStrength(RootStore.getPasswordStrengthScore(newPswInput.text, root.onboarding))
                if (textField.text.length === confirmPswInput.text.length) {
                    root.checkPasswordMatches(false)
                }
            }
            Keys.onReturnPressed: { root.returnPressed() }

            StatusFlatRoundButton {
                id: showHideNewIcon
                visible: newPswInput.text !== ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                width: Style.dp(24)
                height: Style.dp(24)
                icon.name: newPswInput.showPassword ? "hide" : "show"
                icon.color: Theme.palette.baseColor1

                onClicked: newPswInput.showPassword = !newPswInput.showPassword
            }
        }

        StatusPasswordStrengthIndicator {
            id: strengthInditactor
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            value: Math.min(root.minPswLen, newPswInput.text.length)
            from: 0
            to: root.minPswLen
            labelVeryWeak: qsTr("Very weak")
            labelWeak: qsTr("Weak")
            labelSoso: qsTr("So-so")
            labelGood: qsTr("Good")
            labelGreat: qsTr("Great")
        }
    }

    StatusBaseText {
        id: strengthenTxt
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.strengthenText
        font.pixelSize: Style.current.tertiaryTextFontSize
        color: Theme.palette.baseColor1
    }

    Row {
        spacing: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

        StatusBaseText {
            id: lowerCaseTxt
            text: "• " + qsTr("Lower case")
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: d.containsLower ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: upperCaseTxt
            text: "• " + qsTr("Upper case")
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: d.containsUpper ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: numbersTxt
            text: "• " + qsTr("Numbers")
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: d.containsNumbers ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: symbolsTxt
            text: "• " + qsTr("Symbols")
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: d.containsSymbols ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }
    }

    // TODO replace with StatusInput as soon as it supports password
    Input {
        id: confirmPswInput

        property bool showPassword

        z: root.zFront
        width: parent.width
        placeholderText: qsTr("Confirm password")
        textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
        textField.validator: d.validator
        keepHeight: true
        textField.rightPadding: showHideConfirmIcon.width + showHideConfirmIcon.anchors.rightMargin + Style.current.padding / 2

        onTextChanged: {
            d.passwordValidation();
            if(textField.text.length === newPswInput.text.length) {
                root.checkPasswordMatches()
            }
        }

        textField.onFocusChanged: {
            // When clicking into the confirmation input, validate if new password:
            if(textField.focus) {
                d.passwordValidation()
            }
            // When leaving the confirmation input because of the button or other input component is focused, check if password matches
            else {
                root.checkPasswordMatches(false)
            }
        }
        Keys.onReturnPressed: { root.returnPressed() }

        StatusFlatRoundButton {
            id: showHideConfirmIcon
            visible: confirmPswInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            width: Style.dp(24)
            height: Style.dp(24)
            icon.name: confirmPswInput.showPassword ? "hide" : "show"
            icon.color: Theme.palette.baseColor1

            onClicked: confirmPswInput.showPassword = !confirmPswInput.showPassword
        }
    }

    StatusBaseText {
        id: errorTxt
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Style.current.tertiaryTextFontSize
        color: Theme.palette.dangerColor1
        onTextChanged: {
            if(text === "") filler.visible = true
            else filler.visible = false
        }
    }

    // Just a column filler to keep the component height althought errorTxt.text is ""
    Item {
        id: filler
        width: root.width
        visible: true
        height: errorTxt.height
    }
}

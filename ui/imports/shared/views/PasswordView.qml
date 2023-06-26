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

ColumnLayout {
    id: root

    property bool ready: newPswInput.text.length >= Constants.minPasswordLength && newPswInput.text === confirmPswInput.text && errorTxt.text === ""
    property bool createNewPsw: true
    property string title: qsTr("Create a password")
    property bool titleVisible: true
    property string introText: qsTr("Create a password to unlock Status on this device & sign transactions.")
    property string recoverText: qsTr("You will not be able to recover this password if it is lost.")
    property string strengthenText: qsTr("Minimum %n character(s). To strengthen your password consider including:", "", Constants.minPasswordLength)
    property bool highSizeIntro: false

    property var passwordStrengthScoreFunction: function () {}

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
        if (confirmPswInput.text.length === 0) {
            return
        }

        if (onlyIfConfirmPasswordHasFocus && !confirmPswInput.focus) {
            return
        }

        if(newPswInput.text.length >= Constants.minPasswordLength) {
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

        readonly property var validatorRegexp: /^[!-~]{0,64}$/
        readonly property string validatorErrMessage: qsTr("Only letters, numbers, underscores and hyphens allowed")

        // Password strength categorization / validation
        function lowerCaseValidator(text) { return (/[a-z]/.test(text)) }
        function upperCaseValidator(text) { return (/[A-Z]/.test(text)) }
        function numbersValidator(text) { return (/\d/.test(text)) }
        // That incudes NOT extended ASCII printable symbols less space:
        function symbolsValidator(text) { return (/[!-\/:-@[-`{-~]/.test(text)) }

        function validateCharacterSet(text) {
            if(!(d.validatorRegexp).test(text)) {
                errorTxt.text = d.validatorErrMessage
                return false
            }

            return true
        }

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
            // 3 rules to validate:
            // * Password is in pwnd passwords database
            if(isInPwndDatabase())
                errorTxt.text = qsTr("This password has been pwned and shouldn't be used")

            // * Common password
            else if(isCommonPassword())
                errorTxt.text = qsTr("This password is a common word and shouldn't be used")

            // * Password too short
            else if(isTooShort())
                errorTxt.text = qsTr("Password must be at least %n character(s) long", "", Constants.minPasswordLength)
        }

        function isInPwndDatabase() {
            // "TODO - Nice To Have: Pwnd password validation NOT implemented yet! "
            return false
        }

        function isCommonPassword() {
            // "TODO - Nice To Have: Common password validation NOT implemented yet! "
            return false
        }

        function isTooShort() { return newPswInput.text.length < Constants.minPasswordLength }
    }

    spacing: Style.current.bigPadding
    z: root.zFront

    // View visual content:
    StatusBaseText {
        id: title
        Layout.alignment: Qt.AlignHCenter
        visible: root.titleVisible
        text: root.title
        font.pixelSize: 22
        font.bold: true
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: introTxtField
        Layout.fillWidth: true
        text: "%1 <font color=\"%2\">%3</font>".arg(root.introText).arg(Theme.palette.dangerColor1).arg(root.recoverText)
        font.pixelSize: root.highSizeIntro ? 15 : 12
        color: Theme.palette.baseColor1
        wrapMode: Text.WordWrap
        horizontalAlignment: TextEdit.AlignHCenter
    }

    StatusPasswordInput {
        id: currentPswInput
        objectName: "passwordViewCurrentPassword"

        property bool showPassword

        z: root.zFront
        visible: !root.createNewPsw
        Layout.fillWidth: true
        placeholderText: qsTr("Current password")
        echoMode: showPassword ? TextInput.Normal : TextInput.Password
        rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2
        onAccepted: root.returnPressed()

        StatusFlatRoundButton {
            id: showHideCurrentIcon
            visible: currentPswInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            width: 24
            height: 24
            icon.name: currentPswInput.showPassword ? "hide" : "show"
            icon.color: Theme.palette.baseColor1

            onClicked: currentPswInput.showPassword = !currentPswInput.showPassword
        }
    }

    ColumnLayout {
        spacing: Style.current.padding / 2
        z: root.zFront
        Layout.fillWidth: true

        StatusPasswordInput {
            id: newPswInput
            objectName: "passwordViewNewPassword"

            property bool showPassword

            Layout.fillWidth: true
            placeholderText: qsTr("New password")
            echoMode: showPassword ? TextInput.Normal : TextInput.Password
            rightPadding: showHideNewIcon.width + showHideNewIcon.anchors.rightMargin + Style.current.padding / 2

            onTextChanged: {
                // Update password checkers
                errorTxt.text = ""
                // Update strength indicator:
                strengthInditactor.strength = d.convertStrength(root.passwordStrengthScoreFunction(newPswInput.text))

                if(!d.validateCharacterSet(text)) return

                d.containsLower = d.lowerCaseValidator(text)
                d.containsUpper = d.upperCaseValidator(text)
                d.containsNumbers = d.numbersValidator(text)
                d.containsSymbols = d.symbolsValidator(text)

                if (text.length === confirmPswInput.text.length) {
                    root.checkPasswordMatches(false)
                }
            }
            onAccepted: root.returnPressed()

            StatusFlatRoundButton {
                id: showHideNewIcon
                visible: newPswInput.text !== ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16
                width: 24
                height: 24
                icon.name: newPswInput.showPassword ? "hide" : "show"
                icon.color: Theme.palette.baseColor1

                onClicked: newPswInput.showPassword = !newPswInput.showPassword
            }
        }

        StatusPasswordStrengthIndicator {
            id: strengthInditactor
            Layout.fillWidth: true
            value: Math.min(Constants.minPasswordLength, newPswInput.text.length)
            from: 0
            to: Constants.minPasswordLength
            labelVeryWeak: qsTr("Very weak")
            labelWeak: qsTr("Weak")
            labelSoso: qsTr("So-so")
            labelGood: qsTr("Good")
            labelGreat: qsTr("Great")
        }
    }

    StatusBaseText {
        id: strengthenTxt
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        text: root.strengthenText
        font.pixelSize: 12
        color: Theme.palette.baseColor1
        clip: true
    }

    RowLayout {
        spacing: Style.current.padding
        Layout.alignment: Qt.AlignHCenter

        StatusBaseText {
            id: lowerCaseTxt
            text: "• " + qsTr("Lower case")
            font.pixelSize: 12
            color: d.containsLower ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: upperCaseTxt
            text: "• " + qsTr("Upper case")
            font.pixelSize: 12
            color: d.containsUpper ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: numbersTxt
            text: "• " + qsTr("Numbers")
            font.pixelSize: 12
            color: d.containsNumbers ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }

        StatusBaseText {
            id: symbolsTxt
            text: "• " + qsTr("Symbols")
            font.pixelSize: 12
            color: d.containsSymbols ? Theme.palette.successColor1 : Theme.palette.baseColor1
        }
    }

    StatusPasswordInput {
        id: confirmPswInput
        objectName: "passwordViewNewPasswordConfirm"

        property bool showPassword

        z: root.zFront
        Layout.fillWidth: true
        placeholderText: qsTr("Confirm password")
        echoMode: showPassword ? TextInput.Normal : TextInput.Password
        rightPadding: showHideConfirmIcon.width + showHideConfirmIcon.anchors.rightMargin + Style.current.padding / 2

        onTextChanged: {
            errorTxt.text = ""

            if(!d.validateCharacterSet(newPswInput.text)) return

            d.passwordValidation();
            if(text.length === newPswInput.text.length) {
                root.checkPasswordMatches()
            }
        }

        onFocusChanged: {
            // When clicking into the confirmation input, validate if new password:
            if(focus) {
                d.passwordValidation()
            }
            // When leaving the confirmation input because of the button or other input component is focused, check if password matches
            else {
                root.checkPasswordMatches(false)
            }
        }
        onAccepted: root.returnPressed()

        StatusFlatRoundButton {
            id: showHideConfirmIcon
            visible: confirmPswInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            width: 24
            height: 24
            icon.name: confirmPswInput.showPassword ? "hide" : "show"
            icon.color: Theme.palette.baseColor1

            onClicked: confirmPswInput.showPassword = !confirmPswInput.showPassword
        }
    }

    StatusBaseText {
        id: errorTxt
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        font.pixelSize: 12
        color: Theme.palette.dangerColor1
    }
}

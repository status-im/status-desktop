import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
Column {
    id: root

    property bool ready: newPswInput.text.length >= root.minPswLen && newPswInput.text === confirmPswInput.text && errorTxt.text === ""
    property int minPswLen: 6
    property bool createNewPsw: true
    property string title: qsTr("Create a password")
    property bool titleVisible: true
    property string introText: qsTr("Create a password to unlock Status on this device & sign transactions.")
    property string recoverText: qsTr("You will not be able to recover this password if it is lost.")
    property string strengthenText: qsTr("Minimum 6 characers. To strengthen your password consider including:")
    readonly property int zBehind: 1
    readonly property int zFront: 100

    property alias currentPswText: currentPswInput.text
    property alias newPswText: newPswInput.text
    property alias confirmationPswText: confirmPswInput.text
    property alias errorMsgText: errorTxt.text

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

    function checkPasswordMatches() {
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

        readonly property var validator: RegExpValidator { regExp: /^[!-~]+$/ } // That incudes NOT extended ASCII printable characters less space

        // Password strength categorization / validation
        function lowerCaseValidator(text) { return (/[a-z]/.test(text)) }
        function upperCaseValidator(text) { return (/[A-Z]/.test(text)) }
        function numbersValidator(text) { return (/\d/.test(text)) }
        // That incudes NOT extended ASCII printable symbols less space:
        function symbolsValidator(text) { return (/[!-\/:-@[-`{-~]/.test(text)) }
        function findUniqueChars(text) {
            // The variable that contains the unique values
            let uniq = "";

            for(let i = 0; i < text.length; i++) {
                // Checking if the uniq contains the character
                if(uniq.includes(text[i]) === false) {
                    // If the character not present in uniq
                    // Concatenate the character with uniq
                    uniq += text[i]
                }
            }
            return uniq
        }

        // Algorithm defined in functional requirements / Password categorization
        function getPswStrength() {
            let rules = 0
            let points = 0
            let strengthType = StatusPasswordStrengthIndicator.Strength.None

            if(newPswInput.text.length >= root.minPswLen) { points += 10; rules++ }
            if(d.containsLower) { points += 5; rules++ }
            if(d.containsUpper) { points += 5; rules++ }
            if(d.containsNumbers) { points += 5; rules++ }
            if(d.containsSymbols) { points += 10; rules++ }

            let uniq = d.findUniqueChars(newPswInput.text)
            if(uniq.length >= 5) { points += 5; rules++ }

            // Update points according to rules used:
            points += rules * 10/*factor*/

            // Strength decision taken:
            if(points > 0 && points < 40) strengthType = StatusPasswordStrengthIndicator.Strength.VeryWeak
            else if(points >= 40 && points < 60) strengthType = StatusPasswordStrengthIndicator.Strength.Weak
            else if(points >= 60 && points < 80) strengthType = StatusPasswordStrengthIndicator.Strength.SoSo
            else if(points >= 80 && points < 100) strengthType = StatusPasswordStrengthIndicator.Strength.Good
            else if(points >= 100) strengthType = StatusPasswordStrengthIndicator.Strength.Great
            return strengthType
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
                errorTxt.text = qsTr("Password must be at least 6 characters long")
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
    width: 416

    // View visual content:
    StatusBaseText {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.titleVisible
        text: root.title
        font.pixelSize: 22
        font.bold: true
        color: Theme.palette.directColor1
    }

    Column {
        StatusBaseText {
            id: introTxt
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.introText
            font.pixelSize: 12
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            id: recoverTxt
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.recoverText
            font.pixelSize: 12
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
                strengthInditactor.strength = d.getPswStrength()
            }

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
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            value: newPswInput.text.length > root.minPswLen ? root.minPswLen : newPswInput.text.length
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
        font.pixelSize: 12
        color: Theme.palette.baseColor1
    }

    Row {
        spacing: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

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

        onTextChanged: { if(textField.text.length === newPswInput.text.length) root.checkPasswordMatches() }
        textField.onFocusChanged: {
            // When clicking into the confirmation input, validate if new password:
            if(textField.focus) d.passwordValidation()

            // When leaving the confirmation input because of the button or other input component is focused, check if password matches
            else root.checkPasswordMatches(true)
        }

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
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 12
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

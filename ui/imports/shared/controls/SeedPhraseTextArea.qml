import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "./"
import "../"
import "../panels"

Item {
    property bool correctWordCount: Utils.seedPhraseValidWordCount(mnemonicTextField.text)
    property alias textArea: mnemonicTextField.textField
    signal enterPressed()
    property var nextComponentTab
    property bool hideRectangle: false

    id: root
    // Width controlled by parent component
    height: childrenRect.height

    function validateSeed() {
        errorText.text = "";

        if (!Utils.isMnemonic(mnemonicTextField.textField.text)) {
            errorText.text = qsTr("Invalid seed phrase")
        } else {
            errorText.text = onboardingModule.validateMnemonic(mnemonicTextField.textField.text)
            const regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
            if (regex.test(errorText.text)) {
                errorText.text = qsTr("Invalid seed phrase") + '. ' +
                        qsTr("This seed phrase doesn't match our supported dictionary. Check for misspelled words.")
            }
        }
        return errorText.text === ""
    }

    StyledTextArea {
        id: mnemonicTextField
        customHeight: textField.implicitHeight >= 150 ? 150 : textField.implicitHeight + 30
        hideRectangle: root.hideRectangle
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        textField.wrapMode: Text.WordWrap
        textField.horizontalAlignment: TextEdit.AlignHCenter
        textField.verticalAlignment: TextEdit.AlignVCenter
        textField.font.pixelSize: 15
        textField.font.weight: Font.DemiBold
        placeholderText: qsTr("Start with the first word")
        textField.placeholderTextColor: Style.current.secondaryText
        textField.selectByMouse: true
        textField.selectByKeyboard: true
        textField.selectionColor: Style.current.secondaryBackground
        textField.selectedTextColor: Style.current.secondaryText

        onKeyPressed: {
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                event.accepted = true
                root.enterPressed()
                return
            }

            errorText.text = ""
        }

        textField.color: Style.current.textColor
    }

    StyledText {
        visible: errorText.text === ""
        text: Utils.seedPhraseWordCountText(mnemonicTextField.textField.text)
        anchors.right: parent.right
        anchors.top: mnemonicTextField.bottom
        anchors.topMargin: Style.current.smallPadding
        color: correctWordCount ? Style.current.textColor : Style.current.secondaryText
    }

    StyledText {
        id: errorText
        visible: !!text && text !== ""
        wrapMode: Text.WordWrap
        color: Style.current.danger
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mnemonicTextField.bottom
        anchors.topMargin: Style.current.smallPadding
        horizontalAlignment: Text.AlignHCenter
    }
}

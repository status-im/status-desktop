import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    property var onConfirmSeedClick: function () {}
    property alias error: errorText.text
    id: popup
    title: qsTr("Enter seed phrase")
    height: 400

    onOpened: {
        mnemonicTextField.text = "";
        mnemonicTextField.forceActiveFocus(Qt.MouseFocusReason)
    }
    TextArea {
        id: mnemonicTextField
        anchors.top: parent.top
        anchors.topMargin: 40
        height: 100
        anchors.left: parent.left
        anchors.leftMargin: 76
        anchors.right: parent.right
        anchors.rightMargin: 76
        wrapMode: Text.WordWrap
        horizontalAlignment: TextEdit.AlignHCenter
        verticalAlignment: TextEdit.AlignVCenter
        font.pixelSize: 15
        font.weight: Font.DemiBold
        placeholderText: qsTr("Start with the first word")
        placeholderTextColor: Style.current.secondaryText
        selectByMouse: true
        selectByKeyboard: true
        selectionColor: Style.current.secondaryBackground
        selectedTextColor: Style.current.secondaryText
        
        color: Style.current.textColor

        Keys.onReturnPressed: {
            submitBtn.clicked()
        }
        KeyNavigation.priority: KeyNavigation.BeforeItem
        KeyNavigation.tab: submitBtn
    }

    StyledText {
        text: Utils.seedPhraseWordCountText(mnemonicTextField.text)
        anchors.right: parent.right
        anchors.top: mnemonicTextField.bottom
        anchors.topMargin: Style.current.smallPadding
        color: Style.current.secondaryText
    }

    StyledText {
        id: errorText
        visible: !!text && text != ""
        color: Style.current.danger
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mnemonicTextField.bottom
        anchors.topMargin: Style.current.smallPadding
        horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
        id: helpText
        //% "Enter 12, 15, 18, 21 or 24 words.\nSeperate words by a single space."
        text: qsTrId("enter-12--15--18--21-or-24-words--nseperate-words-by-a-single-space-")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        horizontalAlignment: TextEdit.AlignHCenter
        color: Style.current.secondaryText
        font.pixelSize: 12
    }

    footer: StatusRoundButton {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        enabled: mnemonicTextField.text.length > 0

        onClicked : {
            if (mnemonicTextField.text === "") {
                return
            }
            onConfirmSeedClick(mnemonicTextField.text)
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/

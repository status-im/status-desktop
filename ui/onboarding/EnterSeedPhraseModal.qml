import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    property var onConfirmSeedClick: function () {}
    id: popup
    //% "Enter seed phrase"
    title: qsTrId("enter-seed-phrase")
    height: 400 * scaleAction.factor

    onOpened: {
        seedPhraseTextArea.textArea.text = "";
        seedPhraseTextArea.textArea.forceActiveFocus(Qt.MouseFocusReason)
    }

    SeedPhraseTextArea {
        id: seedPhraseTextArea
        anchors.top: parent.top
        anchors.topMargin: 40
        width: parent.width
        hideRectangle: true

        textArea.anchors.leftMargin: 76
        textArea.anchors.rightMargin: 76

        onEnterPressed: submitBtn.clicked()
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
        font.pixelSize: 12 * scaleAction.factor
    }

    footer: StatusRoundButton {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        icon.name: "arrow-right"
        icon.width: 20 * scaleAction.factor
        icon.height: 16 * scaleAction.factor
        enabled: seedPhraseTextArea.correctWordCount

        onClicked : {
            if (seedPhraseTextArea.textArea.text === "") {
                return
            }
            if (seedPhraseTextArea.validateSeed()) {
                onConfirmSeedClick(seedPhraseTextArea.textArea.text)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/

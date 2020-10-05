import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"

ModalPopup {
    property var onConfirmSeedClick: function () {}
    id: popup
    title: qsTr("Enter seed phrase")
    height: 400

    onOpened: {
        mnemonicTextField.text = "";
        mnemonicTextField.forceActiveFocus(Qt.MouseFocusReason)
    }

    TextArea {
        id: mnemonicTextField
        height: 44
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Style.current.primaryTextFontSize
        placeholderText: qsTr("Start with the first word")
        placeholderTextColor: Style.current.secondaryText
        anchors.left: parent.left
        anchors.leftMargin: 76
        anchors.right: parent.right
        anchors.rightMargin: 76
        anchors.verticalCenter: parent.verticalCenter
        color: Style.current.textColor

        Keys.onReturnPressed: {
            submitBtn.clicked()
        }
    }

    StyledText {
        //% "Enter 12, 15, 18, 21 or 24 words.\nSeperate words by a single space."
        text: qsTrId("enter-12--15--18--21-or-24-words--nseperate-words-by-a-single-space-")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: Style.current.secondaryText
        font.pixelSize: Style.current.tertiaryTextFontSize
    }

    footer: Button {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        width: 44
        height: 44
        background: Rectangle {
            radius: 50
            color: Style.current.buttonBackgroundColor
        }

        SVGImage {
            sourceSize.height: 15
            sourceSize.width: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../app/img/arrow-right.svg"
            fillMode: Image.PreserveAspectFit

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Style.current.buttonForegroundColor
                antialiasing: true
            }
        }

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

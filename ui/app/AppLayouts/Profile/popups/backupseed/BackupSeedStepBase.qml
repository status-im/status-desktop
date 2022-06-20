import QtQuick 2.12
import QtQuick.Controls 2.12
import StatusQ.Controls 0.1
import shared.panels 1.0
import StatusQ.Controls.Validators 0.1
import utils 1.0

Item {
    property int wordRandomNumber: -1
    property string wordAtRandomNumber
    property bool secondWordValid: true
    property alias titleText: txtTitle.text
    property alias inputValid: inputText.valid

    StyledText {
        id: txtTitle
        anchors.right: parent.right
        anchors.left: parent.left
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.primaryTextFontSize
    }

    StatusInput {
        id: inputText
        visible: (wordRandomNumber > -1)
        implicitWidth: Style.dp(448)
        input.implicitHeight: Style.dp(44)
        anchors.top: parent.top
        anchors.topMargin: Style.dp(40)
        anchors.horizontalCenter: parent.horizontalCenter
        validationMode: StatusInput.ValidationMode.Always
        label: qsTr("Word #" + (wordRandomNumber+1))
        input.placeholderText: qsTr("Enter word")
        validators: [
            StatusValidator {
                validate: function (t) { return (wordAtRandomNumber === inputText.text); }
                errorMessage: (inputText.text.length) > 0 ? qsTr("Wrong word") : ""
            }
        ]
    }
}

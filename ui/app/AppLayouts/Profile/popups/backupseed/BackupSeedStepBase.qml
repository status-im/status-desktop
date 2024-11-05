import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.panels 1.0
import utils 1.0

StatusScrollView {
    id: root

    property int wordRandomNumber: -1
    property string wordAtRandomNumber
    property bool secondWordValid: true
    property alias titleText: txtTitle.text
    property alias inputValid: inputText.valid

    default property alias content: column.children

    signal enterPressed()

    function forceInputFocus() {
        inputText.input.edit.forceActiveFocus();
    }

    contentWidth: availableWidth
    clip: false

    ColumnLayout {
        id: column
        width: root.availableWidth
        spacing: Theme.padding

        StyledText {
            id: txtTitle
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            Layout.fillWidth: true
        }

        StatusInput {
            id: inputText
            input.edit.objectName: "BackupSeedStepBase_inputText"
            visible: (wordRandomNumber > -1)
            implicitWidth: 448
            label: qsTr("Word #%1").arg(wordRandomNumber + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) { return (root.wordAtRandomNumber === inputText.text); }
                    errorMessage: qsTr("Wrong word")
                }
            ]
            Layout.fillWidth: true
            onKeyPressed: {
                if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && inputText.valid) {
                    root.enterPressed();
                }
            }
        }
    }
}

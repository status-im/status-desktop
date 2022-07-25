import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import StatusQ.Core 0.1
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

    implicitHeight: 520

    ColumnLayout {
        id: column
        width: root.availableWidth
        spacing: Style.current.padding

        StyledText {
            id: txtTitle
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.primaryTextFontSize
            Layout.fillWidth: true
        }

        StatusInput {
            id: inputText
            visible: (wordRandomNumber > -1)
            implicitWidth: 448
            input.implicitHeight: 44
            validationMode: StatusInput.ValidationMode.Always
            label: qsTr("Word #%1").arg(wordRandomNumber + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) { return (root.wordAtRandomNumber === inputText.text); }
                    errorMessage: (inputText.text.length) > 0 ? qsTr("Wrong word") : ""
                }
            ]
            Layout.fillWidth: true
        }
    }

    ScrollIndicator.vertical: ScrollIndicator {}
}

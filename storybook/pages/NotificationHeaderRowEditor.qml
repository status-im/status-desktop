import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme


Control {
    property alias titleField: titleField.text
    property alias chatkeyTextField: chatkeyTextField.text
    property alias isContactCheck: isContactCheck.checked
    property alias isTruestedCheck: isTruestedCheck.checked
    property alias changeTitleColor: changeTitleColor.checked
    property alias changeKeyColor: changeKeyColor.checked

    background: Rectangle {
        color: Theme.palette.directColor8
        radius: 8
    }

    contentItem: ColumnLayout {

        Label {
            Layout.topMargin: Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.bottomMargin: Theme.padding
            text: "HEADER ROW EDITOR"
            font.weight: Font.Bold
        }

        Label {
            Layout.leftMargin: Theme.padding
            text: "Title"
        }

        TextField {
            id: titleField
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            Layout.fillWidth: true
            text: "anna.eth"
        }

        Label {
            Layout.leftMargin: Theme.padding
            text: "Chat key"
        }

        TextField {
            id: chatkeyTextField
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            Layout.fillWidth: true
            text: "zQ3saaaedswar2hFSf8wkhHbPsw94NAL5rSggHSYRPfL222TF"
        }

        CheckBox {
            id: isContactCheck
            Layout.leftMargin: Theme.padding
            text: "Is Contact?"
            checked: true
        }

        CheckBox {
            id: isTruestedCheck

            Layout.leftMargin: Theme.padding
            text: "Is Trusted?"
            checked: true
        }

        Switch {
            id: changeTitleColor
            Layout.leftMargin: Theme.padding
            text: "Change Title Color"
        }

        Switch {
            id: changeKeyColor
            Layout.leftMargin: Theme.padding
            text: "Change Key Color"
        }
    }
}


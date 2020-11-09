import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    readonly property int maxDescChars: 140

    id: popup

    onOpened: {
        nameInput.text = "";
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    title: qsTr("New community")

    Input {
        id: nameInput
        label: qsTr("Name your community")
        placeholderText: qsTr("Name")
    }

    StyledTextArea {
        id: descriptionTextArea
        label: qsTr("Give it a short description")
        placeholderText: qsTr("Description")
        validationError: descriptionTextArea.text.length > maxDescChars ? qsTr("The description cannot exceed 140 characters") : ""
        anchors.top: nameInput.bottom
        anchors.topMargin: Style.current.bigPadding
        customHeight: 88
    }

    StyledText {
        id: charLimit
        text: `${descriptionTextArea.text.length}/${maxDescChars}`
        anchors.top: descriptionTextArea.bottom
        anchors.topMargin: !descriptionTextArea.validationError ? 5 : - Style.current.smallPadding
        anchors.right: descriptionTextArea.right
        font.pixelSize: 12
        color: !descriptionTextArea.validationError ? Style.current.textColor : Style.current.danger
    }
    
    footer: StatusButton {
        text: qsTr("Create")
        anchors.right: parent.right
    }
}


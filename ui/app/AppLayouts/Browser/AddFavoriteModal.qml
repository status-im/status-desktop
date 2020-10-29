import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"

ModalPopup {
    property string urlError: ""
    property string nameError: ""

    id: popup
    width: 480
    height: 480

    onOpened: {
        urlInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function validate() {
        urlError = ""
        if (!urlInput.text) {
            urlError = qsTr("Please enter a URL")
        } else if (!Utils.isURL(urlInput.text)) {
            urlError = qsTr("This fields needs to be a valid URL")
        }

        nameError = !nameInput.text ? qsTr("Please enter a Name") : ""

        return !urlError && !nameError
    }

    title: qsTr("Add favorite")

    Column {
        width: parent.width
        spacing: Style.current.padding

        Input {
            id: urlInput
            label: qsTr("URL")
            placeholderText: qsTr("Paste URL")
            pasteFromClipboard: true
            validationError: popup.urlError
        }

        Input {
            id: nameInput
            label: qsTr("Name")
            placeholderText: qsTr("Name the website")
            validationError: popup.nameError
        }
    }

    footer: StyledButton {
        id: addBtn
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        label: qsTr("Add")
        anchors.bottom: parent.bottom
        onClicked: {
            if (!validate()) {
                return
            }

            browserModel.addBookmark(urlInput.text, nameInput.text)
            popup.close()
        }
    }
}

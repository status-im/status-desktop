import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    id: popup

    title: qsTr("Homepage")

    onClosed: {
        destroy()
    }

    Column {
        spacing: Style.current.bigPadding
        width: parent.width

        ButtonGroup {
            id: homepageGroup
        }

        StatusRadioButton {
            text: qsTr("Default")
            ButtonGroup.group: homepageGroup
            checked: appSettings.browserHomepage === ""
            onCheckedChanged: {
                if (checked) {
                    appSettings.browserHomepage = ""
                    customUrl.visible = false
                }
            }
        }

        StatusRadioButton {
            text: qsTr("Custom...")
            ButtonGroup.group: homepageGroup
            checked: appSettings.browserHomepage !== "" || customUrl.visible
            onClicked: {
                customUrl.visible = true
            }
        }

        Input {
            id: customUrl
            visible: appSettings.browserHomepage !== ""
            placeholderText: qsTr("Paste URL")
            text: appSettings.browserHomepage
            pasteFromClipboard: true
            textField.onTextChanged: {
                appSettings.browserHomepage = customUrl.text
            }
        }
    }
}


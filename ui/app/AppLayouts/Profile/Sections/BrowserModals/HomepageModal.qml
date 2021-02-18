import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    id: popup

    //% "Homepage"
    title: qsTrId("homepage")

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
            //% "Default"
            text: qsTrId("default")
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
            //% "Custom..."
            text: qsTrId("custom---")
            ButtonGroup.group: homepageGroup
            checked: appSettings.browserHomepage !== "" || customUrl.visible
            onClicked: {
                customUrl.visible = true
            }
        }

        Input {
            id: customUrl
            visible: appSettings.browserHomepage !== ""
            //% "Paste URL"
            placeholderText: qsTrId("paste-url")
            text: appSettings.browserHomepage
            pasteFromClipboard: true
            textField.onTextChanged: {
                appSettings.browserHomepage = customUrl.text
            }
        }
    }
}


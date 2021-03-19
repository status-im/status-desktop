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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: Style.current.padding

        ButtonGroup {
            id: homepageGroup
        }

        StatusRadioButtonRow {
            //% "Default"
            text: qsTrId("default")
            buttonGroup: homepageGroup
            checked: appSettings.browserHomepage === ""
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.browserHomepage = ""
                    customUrl.visible = false
                }
            }
        }

        StatusRadioButtonRow {
            //% "Custom..."
            text: qsTrId("custom---")
            buttonGroup: homepageGroup
            checked: appSettings.browserHomepage !== "" || customUrl.visible
            onRadioCheckedChanged: {
                if (checked) {
                    customUrl.visible = true
                }
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
            anchors.leftMargin: 0
            anchors.rightMargin: 0
        }
    }
}


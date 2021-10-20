import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/controls"
import "../../../../shared/popups"
import "../../../../shared/status"

// TODO: replace with StatusModal
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
            checked: localAccountSensitiveSettings.browserHomepage === ""
            onRadioCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.browserHomepage = ""
                    customUrl.visible = false
                }
            }
        }

        StatusRadioButtonRow {
            //% "Custom..."
            text: qsTrId("custom---")
            buttonGroup: homepageGroup
            checked: localAccountSensitiveSettings.browserHomepage !== "" || customUrl.visible
            onRadioCheckedChanged: {
                if (checked) {
                    customUrl.visible = true
                }
            }
        }

        Input {
            id: customUrl
            visible: localAccountSensitiveSettings.browserHomepage !== ""
            //% "Paste URL"
            placeholderText: qsTrId("paste-url")
            text: localAccountSensitiveSettings.browserHomepage
            pasteFromClipboard: true
            textField.onTextChanged: {
                localAccountSensitiveSettings.browserHomepage = customUrl.text
            }
            anchors.leftMargin: 0
            anchors.rightMargin: 0
        }
    }
}


import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import shared.popups 1.0
import shared.controls 1.0

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

        RadioButtonSelector {
            //% "Default"
            title: qsTrId("default")
            buttonGroup: homepageGroup
            checked: localAccountSensitiveSettings.browserHomepage === ""
            onCheckedChanged: {
                if (checked) {
                    localAccountSensitiveSettings.browserHomepage = ""
                    customUrl.visible = false
                }
            }
        }

        RadioButtonSelector {
            //% "Custom..."
            title: qsTrId("custom---")
            buttonGroup: homepageGroup
            checked: localAccountSensitiveSettings.browserHomepage !== "" || customUrl.visible
            onCheckedChanged: {
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


import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    property var profileStore

    onOpened: {
        displayNameInput.forceActiveFocus(Qt.MouseFocusReason);
    }

    contentItem: Item {
        width: popup.width
        height: childrenRect.height

        Column {
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
            spacing: 16

            Input {
                id: displayNameInput
                placeholderText: "DisplayName"
                text: popup.profileStore.displayName
                //validationError: popup.nicknameTooLong ? qsTrId("your-nickname-is-too-long") : ""
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: doneBtn
            text: "Ok"
           // enabled: !popup.nicknameTooLong
            onClicked: {
               popup.profileStore.setDisplayName(displayNameInput.text)
            }
        }
    ]
}


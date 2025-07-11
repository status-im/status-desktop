import QtQuick

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Popups
import StatusQ.Core.Theme

StatusModal {
    id: root

    headerSettings.title: "Contact Requests"
    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "notification"
    }

    contentItem: StatusBaseText {
        anchors.centerIn: parent
        text: "Contact request will be shown here"
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.directColor1
    }

    rightButtons: [
        StatusButton {
            text: "Decline all"
            type: StatusBaseButton.Type.Danger
            onClicked: root.close()
        },
        StatusButton {
            text: "Accept all"
            onClicked: root.close()
        }
    ]
}

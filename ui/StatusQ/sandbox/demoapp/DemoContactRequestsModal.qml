import QtQuick 2.12

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1

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
        font.pixelSize: 15
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

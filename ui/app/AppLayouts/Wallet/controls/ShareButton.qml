import QtQuick 2.15

import StatusQ.Controls 0.1

StatusButton {
    id: root

    text: qsTr("Share")
    type: StatusBaseButton.Type.Normal
    size: StatusBaseButton.Size.Tiny

    horizontalPadding: 8
    verticalPadding: 3
    implicitHeight: 22

    radius: 20
    font.pixelSize: 12
    font.weight: Font.Normal

    Timer {
        id: shareStateTimer
        interval: 2000
        repeat: false
    }

    states: State {
        name: "success"
        when: shareStateTimer.running
        PropertyChanges {
            target: shareButton
            text: qsTr("Copied")
            type: StatusBaseButton.Type.Success
            icon.name: "tiny/checkmark"
            tooltip.text: qsTr("Copied to clipboard")
        }
    }

    onClicked: {
        shareStateTimer.restart()
    }
}

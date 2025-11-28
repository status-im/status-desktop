import QtQuick

import StatusQ.Core.Theme

import shared.controls
import utils

InformationTag {
    id: root

    property bool success: false

    tagPrimaryLabel.text: qsTr("Connected. You can now go back to the dApp.")
    tagPrimaryLabel.color: Theme.palette.directColor1
    tagPrimaryLabel.font.pixelSize: Theme.additionalTextSize
    backgroundColor: Theme.palette.successColor3
    bgBorderColor: StatusColors.alphaColor(Theme.palette.successColor1, 0.4)
    asset.color: tagPrimaryLabel.color
    verticalPadding: Theme.halfPadding
    horizontalPadding: 12
    leftComponent: successBadge

    states: [
        State {
            name: "error"
            when: !root.success
            PropertyChanges { target: tagPrimaryLabel; text: qsTr("Error connecting to dApp. Close and try again") }
            PropertyChanges { target: tagPrimaryLabel; color: Theme.palette.dangerColor1 }
            PropertyChanges { target: asset; name: "warning" }
            PropertyChanges {
                target: root
                backgroundColor: Theme.palette.dangerColor3
                bgBorderColor: StatusColors.alphaColor(Theme.palette.dangerColor1, 0.4)
            }
        }
    ]

    ColorAnimation on backgroundColor { running: root.success && root.visible; to: Theme.palette.successColor2; duration: 2000 }
    ColorAnimation on backgroundColor { running: !root.success && root.visible; to: "transparent"; duration: 2000 }
    ColorAnimation on bgBorderColor { running: root.success && root.visible; to: Theme.palette.successColor3; duration: 2000 }
    ColorAnimation on bgBorderColor { running: !root.success && root.visible; to: Theme.palette.dangerColor2; duration: 2000 }

    Component {
        id: successBadge
        Item {
            width: visible ? 10 : 0
            height: visible ? 6 : 0
            visible: root.success
            Rectangle {
                width: 6
                height: 6
                radius: width / 2
                color: Theme.palette.successColor1
            }
        }
    }
}
import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    spacing: 10
    Grid {
        id: buttonGridWidth
        columns: 3
        columnSpacing: 38
        rowSpacing: 10

        horizontalItemAlignment: Grid.AlignHCenter

        // Large
        StatusButton {
            text: "Button"
        }

        StatusButton {
            text: "Button"
            enabled: false
        }

        StatusButton {
            text: "Button"
            loading: true
        }

        StatusButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
        }

        StatusButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            enabled: false
        }

        StatusButton {
            text: "Button"
            loading: true
            type: StatusBaseButton.Type.Danger
        }

        StatusFlatButton {
            text: "Button"
        }

        StatusFlatButton {
            text: "Button"
            enabled: false

        }

        StatusFlatButton {
            text: "Button"
            loading: true
        }

        StatusFlatButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
        }

        StatusFlatButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            enabled: false
        }

        StatusFlatButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            loading: true
        }

        // Small
        StatusButton {
            text: "Button"
            size: StatusBaseButton.Size.Small
        }

        StatusButton {
            text: "Button"
            enabled: false
            size: StatusBaseButton.Size.Small
        }

        StatusButton {
            text: "Button"
            size: StatusBaseButton.Size.Small
            loading: true
        }

        StatusButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            size: StatusBaseButton.Size.Small
        }

        StatusButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            size: StatusBaseButton.Size.Small
            enabled: false
        }

        StatusButton {
            text: "Button"
            type: StatusBaseButton.Type.Danger
            size: StatusBaseButton.Size.Small
            loading: true
        }

        StatusFlatButton {
            text: "Button"
            size: StatusBaseButton.Size.Small
        }

        StatusFlatButton {
            text: "Button"
            enabled: false
            size: StatusBaseButton.Size.Small
        }

        StatusFlatButton {
            text: "Button"
            enabled: false
            size: StatusBaseButton.Size.Small
            loading: true
        }

        // Icon buttons

        // blue

        StatusRoundButton {
            icon.name: "info"
        }

        StatusRoundButton {
            icon.name: "info"
            enabled: false
        }

        StatusRoundButton {
            icon.name: "info"
            loading: true
        }

        // black

        StatusRoundButton {
            type: StatusRoundButton.Type.Secondary
            icon.name: "info"
        }

        StatusRoundButton {
            type: StatusRoundButton.Type.Secondary
            icon.name: "info"
            enabled: false
        }

        StatusRoundButton {
            type: StatusRoundButton.Type.Secondary
            icon.name: "info"
            loading: true
        }

        // Rounded blue

        StatusFlatRoundButton {
            width: 44
            height: 44

            icon.name: "info"
        }

        StatusFlatRoundButton {
            width: 44
            height: 44
            icon.name: "info"
            enabled: false
        }

        StatusFlatRoundButton {
            width: 44
            height: 44
            icon.name: "info"
            loading: true
        }

        // Rounded white

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 44
            height: 44

            icon.name: "info"
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 44
            height: 44
            icon.name: "info"
            enabled: false
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 44
            height: 44
            icon.name: "info"
            loading: true
        }

        StatusFlatButton {
            icon.name: "info"
            text: "Button"
            size: StatusBaseButton.Size.Small
        }
        StatusFlatButton {
            icon.name: "info"
            text: "Button"
            enabled: false
            size: StatusBaseButton.Size.Small
        }

        StatusFlatButton {
            icon.name: "info"
            text: "Button"
            loading: true
            size: StatusBaseButton.Size.Small
        }

        // Tertiary
        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            icon.name: "gif"
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            icon.name: "gif"
            enabled: false
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            icon.name: "gif"
            loading: true
        }

        // No background Tertiary
        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            color: "transparent"
            icon.name: "gif"
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            icon.name: "gif"
            color: "transparent"
            enabled: false
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Tertiary
            icon.name: "gif"
            color: "transparent"
            loading: true
        }

        // Quartenery
        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Quaternary
            icon.name: "gif"
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Quaternary
            icon.name: "gif"
            enabled: false
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Quaternary
            icon.name: "gif"
            loading: true
        }
    }

    StatusPickerButton {
        width: buttonGridWidth.width
        bgColor: colorDialog.colorSelected ? colorDialog.color : Theme.palette.baseColor2
        contentColor: colorDialog.colorSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
        text: colorDialog.colorSelected ? colorDialog.color.toString().toUpperCase() : "Pick a color"
        onClicked: {
            colorDialog.open();
        }
    }

    StatusColorDialog {
        id: colorDialog
        anchors.centerIn: parent
        property bool colorSelected: false
        onAccepted: {
            colorSelected = true;
        }
    }

}

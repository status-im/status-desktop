import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components
import StatusQ.Controls

import utils

import "../popups"

StatusListItem {
    id: root

    property var buttonGroup
    property alias checked: radioButton.checked

    implicitHeight: 52

    onClicked: {
        radioButton.checked = true
    }

    components: [
        StatusRadioButton {
            id: radioButton
            ButtonGroup.group: root.buttonGroup
        }
    ]
}


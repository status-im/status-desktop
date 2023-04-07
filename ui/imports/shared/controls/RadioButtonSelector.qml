import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

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


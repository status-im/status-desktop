import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Column {
    id: root

    spacing: 8

    Component.onCompleted: {
        focusedTextArea.forceActiveFocus()
    }

    StatusTextArea {
        id: focusedTextArea
        width: parent.width
        placeholderText: "Initially focused text area"
        KeyNavigation.tab: unfocusedTextArea
    }

    StatusTextArea {
        id: unfocusedTextArea
        width: parent.width
        placeholderText: "Unfocused text area (hover me to see the color change)"
        KeyNavigation.tab: invalidTextArea
    }

    StatusTextArea {
        id: invalidTextArea
        width: parent.width
        valid: false
        placeholderText: "Invalid text area, should display red border"
        KeyNavigation.tab: longTextArea
    }

    StatusScrollView {
        id: scrollView
        padding: 0 // use our own (StatusTextArea) padding
        width: parent.width
        contentWidth: availableWidth
        height: 120
        StatusTextArea {
            id: longTextArea
            width: scrollView.availableWidth
            text: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Integer imperdiet lectus quis justo. Sed vel lectus. \
            Donec odio tempus molestie, porttitor ut, iaculis quis, sem. Morbi scelerisque luctus velit. Nunc auctor. Nullam at \
            arcu a est sollicitudin euismod. Cras elementum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, \
            per inceptos hymenaeos. Fusce aliquam vestibulum ipsum. Etiam sapien elit, consequat eget, tristique non, venenatis quis, ante. \
            Nullam sit amet magna in magna gravida vehicula. Cras pede libero, dapibus nec, pretium sit amet, tempor quis. Nullam faucibus \
            mi quis velit. Nam sed tellus id magna elementum tincidunt. Duis bibendum, lectus ut viverra rhoncus, dolor nunc faucibus libero, \
            eget facilisis enim ipsum id lacus. Maecenas aliquet accumsan leo. Aliquam erat volutpat."
            KeyNavigation.tab: focusedTextArea
        }
    }

    StatusTextArea {
        enabled: false
        placeholderText: "Disabled text area"
    }
}

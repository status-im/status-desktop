import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.panels

Item {
    component Content: Rectangle {
        Layout.fillWidth: true

        height: 50
        border.width: 1
        radius: 10
    }

    SequenceColumnLayout {
        anchors.centerIn: parent
        width: 300

        title: titleTextField.text

        Content {
            color: "red"
        }

        SequenceColumnLayoutSeparator {}

        Content {
            color: "green"
        }

        SequenceColumnLayoutSeparator {}

        Content {
            color: "blue"
        }
    }

    Pane {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            TextField {
                id: titleTextField

                text: "Some title goes here"
            }
            Button {
                text: "Clear"

                onClicked: titleTextField.clear()
            }
        }
    }
}

// category: Panels
// status: good

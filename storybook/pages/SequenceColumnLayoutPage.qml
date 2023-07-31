import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.panels 1.0

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

        SequenceColumnLayout.Separator {}

        Content {
            color: "green"
        }

        SequenceColumnLayout.Separator {}

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

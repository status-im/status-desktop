import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    property var onCancel: function() {}

    id: insertCard
    anchors.centerIn: parent

    showHeader: false
    focus: visible

    contentItem: Item {
        width: insertCard.width
        implicitHeight: childrenRect.height
        Column {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: parent.width
                height: 16
            }

            StatusBaseText {
                text: qsTr("Please insert your Keycard to proceed or press the cancel button to cancel the operation")
                font.pixelSize: 15
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
            }

            Item {
                width: parent.width
                height: 16
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: cancelButton
            text: qsTr("Cancel")
            onClicked: {
              insertCard.close()
              onCancel()
            }
        }
    ]
}

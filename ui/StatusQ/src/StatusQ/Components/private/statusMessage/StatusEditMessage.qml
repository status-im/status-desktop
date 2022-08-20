import QtQuick 2.3
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property alias inputComponent: chatInputLoader.sourceComponent
    property alias active: chatInputLoader.active

    property string cancelButtonText: ""
    property string saveButtonText: ""
    property string msgText: ""

    signal editCancelled()
    signal editCompleted(var newMsgText)

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 4

        Loader {
            id: chatInputLoader
            Layout.fillWidth: true

            /*
                NOTE: sourceComponent must have `messageText` property
                TODO: Replace with StatusChatInput once its moved to StatusQ.
            */

            sourceComponent: StatusInput {
                readonly property string messageText: input.text
                width: parent.width
                input.placeholderText: ""
                input.text: msgText
                maximumHeight: 40
            }
        }

        RowLayout {
            spacing: 4
            StatusFlatButton {
                id: cancelBtn
                text: cancelButtonText
                size: StatusBaseButton.Size.Small
                onClicked: {
                    editCancelled()
                }
            }
            StatusButton {
                id: saveBtn
                text: saveButtonText
                size: StatusBaseButton.Size.Small
                enabled: !!chatInputLoader.item && chatInputLoader.item.messageText.trim().length > 0
                onClicked: {
                    editCompleted(!chatInputLoader.item ? "" : chatInputLoader.item.messageText)
                }
            }
        }
    }
}

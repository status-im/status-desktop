import QtQuick 2.3
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: editText

    property alias inputComponent: chatInputLoader.sourceComponent

    property string cancelButtonText: ""
    property string saveButtonText: ""
    property string msgText: ""

    signal cancelEditClicked()
    signal editCompleted(var newMsgText)

    height: childrenRect.height

    ColumnLayout {
        spacing: 4
        Loader {
            id: chatInputLoader
            // To-Do: Move to StatusChatInput once its moved to StatusQ
            sourceComponent: StatusInput {
                width: editText.width
                placeholderText: ""
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
                onClicked: cancelEditClicked()
            }
            StatusButton {
                id: saveBtn
                text: saveButtonText
                size: StatusBaseButton.Size.Small
                enabled: chatInputLoader.item.input.text.trim().length > 0
                onClicked: editCompleted(chatInputLoader.item.input.text)
            }
        }
    }
}

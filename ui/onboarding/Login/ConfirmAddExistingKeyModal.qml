import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../imports"
import "../../shared"

ModalPopup {
    property var onOpenModalClick: function () {}
    id: popup
    title: qsTr("Enter seed phrase")
    height: 200

    Text {
        text: "Do you want to add another existing key?"
        anchors.left: parent.left
        anchors.top: parent.top
    }

    footer: StyledButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: "Add another existing key"

        onClicked : {
            onOpenModalClick()
            popup.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import StatusQ.Controls 0.1
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: root
    width: 400
    height: 248

    closePolicy: Popup.NoAutoClose

    contentItem: Column {
        implicitWidth: root.width
        implicitHeight: root.height
        spacing: 8
        StatusIcon {
            icon: "check"
        }
        StatusBaseText {
            text: qsTr("You need to sign in again using the new password.")
        }

        StatusButton {
            id: submitBtn
            anchors.right: parent.right
            text: qsTr("Log out")
            onClicked: {
                //quits the app TODO: change this to logout instead when supported
                Qt.quit();
            }
        }
    }
}

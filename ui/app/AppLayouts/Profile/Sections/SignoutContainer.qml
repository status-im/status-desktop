import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: signoutContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: txtTitle
        //% "Sign out controls"
        text: qsTrId("sign-out-controls")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    StyledButton {
        id: btnLogout
        anchors.top: txtTitle.bottom
        anchors.topMargin: Style.current.padding
        //% "Logout"
        // label: qsTrId("logout")
        //% "Exit"
        label: qsTrId("exit")

        onClicked: {
            // profileModel.logout();
            Qt.quit();
        }
    }
}

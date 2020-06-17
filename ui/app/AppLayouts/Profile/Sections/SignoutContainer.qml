import QtQuick 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"

Item {
    id: signoutContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    Text {
        id: txtTitle
        text: qsTr("Sign out controls")
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
        anchors.topMargin: Theme.padding
        // label: qsTr("Logout")
        label: qsTr("Exit")

        onClicked: {
            // profileModel.logout();
            Qt.quit();
        }
    }
}
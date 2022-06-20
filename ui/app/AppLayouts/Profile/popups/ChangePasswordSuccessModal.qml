import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusModal {
    id: root
    width: Style.dp(400)
    height: Style.dp(248)

    closePolicy: Popup.NoAutoClose

    showHeader: false
    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.dp(45)
        spacing: Style.current.halfPadding
        StatusIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Style.dp(26)
            Layout.preferredHeight: Style.dp(26)
            icon: "checkmark"
            color: Style.current.green
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 18
            text: qsTr("<b>Password changed</b>")
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            text: qsTr("You need to sign in again using the new password.")
        }

        StatusButton {
            id: submitBtn
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Sign out & Quit")
            onClicked: {
                //quits the app TODO: change this to logout instead when supported
                Qt.quit();
            }
        }
    }
}

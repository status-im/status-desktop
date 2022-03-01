import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../../Profile/views"

Page {
    id: root

    property string newPassword
    property string confirmationPassword

    signal passwordCreated(string newPassword, string confirmationPassword)
    signal backClicked()

    Component.onCompleted: { view.forceNewPswInputFocus() }

    QtObject {
        id: d
        readonly property int zBehind: 1
        readonly property int zFront: 100
    }

    anchors.fill: parent

    Column {
        spacing: 4 * Style.current.padding
        anchors.centerIn: parent
        z: view.zFront

        PasswordView {
            id: view
            newPswText: root.newPassword
            confirmationPswText: root.confirmationPassword
        }

        StatusButton {
            id: submitBtn
            z: d.zFront
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Create password")
            enabled: view.ready
            onClicked: { passwordCreated(view.newPswText, view.confirmationPswText) }
        }
    }

    // Back button:
    StatusRoundButton {
        z: d.zFront // Focusable / clickable component
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        icon.name: "arrow-left"
        onClicked: { root.backClicked() }
    }

    // By clicking anywhere outside password entries fields or focusable element in the view, it is needed to check if passwords entered matches
    MouseArea {
        anchors.fill: parent
        z: d.zBehind // Behind focusable components
        onClicked: { view.checkPasswordMatches() }
    }
}

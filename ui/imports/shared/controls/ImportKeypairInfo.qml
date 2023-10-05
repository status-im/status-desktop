import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root

    property string title: qsTr("Import keypair to use this account")
    property string info: qsTr("This account was added to one of your synced devices. To use this account you will first need import the associated keypair to this device.")
    property string buttonName: qsTr("Import missing keypair")

    signal runImport()

    radius: Style.current.radius
    border.width: 1
    border.color: Theme.palette.directColor8
    color: Theme.palette.transparent

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        spacing: Style.current.halfPadding

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding
            text: root.title
            color: Theme.palette.warningColor1
        }

        StatusBaseText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.info
        }

        StatusButton {
            Layout.alignment: Qt.AlignLeft
            Layout.bottomMargin: Style.current.padding
            text: root.buttonName
            type: StatusBaseButton.Type.Warning
            icon.name: "download"
            onClicked: {
                root.runImport()
            }
        }
    }
}

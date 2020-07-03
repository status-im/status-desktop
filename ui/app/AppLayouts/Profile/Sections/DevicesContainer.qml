import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: syncContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: sectionTitle
        text: qsTr("Devices")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Item {
        id: firstTimeSetup
        anchors.left: syncContainer.left
        anchors.leftMargin: Theme.padding
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Theme.padding
        anchors.right: syncContainer.right
        anchors.rightMargin: Theme.padding
        visible: !profileModel.deviceSetup

        StyledText {
            id: deviceNameLbl
            text: qsTr("Please set a name for your device.")
            font.pixelSize: 14
        }

        Input {
            id: deviceNameTxt
            placeholderText: qsTr("Specify a name")
            anchors.top: deviceNameLbl.bottom
            anchors.topMargin: Theme.padding
        }

        StyledButton {
            visible: !selectChatMembers
            anchors.top: deviceNameTxt.bottom
            anchors.topMargin: 10
            anchors.right: deviceNameTxt.right
            label: qsTr("Continue")
            disabled: deviceNameTxt.text === ""
            onClicked : profileModel.setDeviceName(deviceNameTxt.text.trim())
        }
    }

    StyledButton {
        anchors.bottom: syncContainer.bottom
        anchors.bottomMargin: Theme.padding
        anchors.right: deviceNameTxt.right
        label: qsTr("Sync all devices")
        onClicked : {
            console.log("TODO")
        }
    }

}

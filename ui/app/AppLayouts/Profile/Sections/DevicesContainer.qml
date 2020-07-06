import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: syncContainer

    property bool isSyncing: false

    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: sectionTitle
        //% "Devices"
        text: qsTrId("devices")
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
        anchors.leftMargin: Style.current.padding
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: syncContainer.right
        anchors.rightMargin: Style.current.padding
        visible: !profileModel.deviceSetup

        StyledText {
            id: deviceNameLbl
            //% "Please set a name for your device."
            text: qsTrId("pairing-please-set-a-name")
            font.pixelSize: 14
        }

        Input {
            id: deviceNameTxt
            //% "Specify a name"
            placeholderText: qsTrId("specify-name")
            anchors.top: deviceNameLbl.bottom
            anchors.topMargin: Style.current.padding
        }

        StyledButton {
            visible: !selectChatMembers
            anchors.top: deviceNameTxt.bottom
            anchors.topMargin: 10
            anchors.right: deviceNameTxt.right
            //% "Continue"
            label: qsTrId("continue")
            disabled: deviceNameTxt.text === ""
            onClicked : profileModel.setDeviceName(deviceNameTxt.text.trim())
        }
    }

    Item {
        anchors.left: syncContainer.left
        anchors.leftMargin: Style.current.padding
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: syncContainer.right
        anchors.rightMargin: Style.current.padding
        visible: profileModel.deviceSetup

        Rectangle {
            id: advertiseDevice
            height: childrenRect.height
            width: 500
            anchors.left: parent.left
            anchors.right: parent.right

            SVGImage {
                id: advertiseImg
                height: 32
                width: 32
                anchors.left: parent.left
                fillMode: Image.PreserveAspectFit
                source: "/app/img/messageActive.svg"
            }

            StyledText {
                id: advertiseDeviceTitle
                //% "Advertise device"
                text: qsTrId("pair-this-device")
                font.pixelSize: 18
                font.weight: Font.Bold
                color: Style.current.blue
                anchors.left: advertiseImg.right
                anchors.leftMargin: Style.current.padding
            }

            StyledText {
                id: advertiseDeviceDesk
                //% "Pair your devices to sync contacts and chats between them"
                text: qsTrId("pair-this-device-description")
                font.pixelSize: 14
                anchors.top: advertiseDeviceTitle.bottom
                anchors.topMargin: 6
                anchors.left: advertiseImg.right
                anchors.leftMargin: Style.current.padding
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: profileModel.advertiseDevice()
            }
        }

        StyledText {
            anchors.top: advertiseDevice.bottom
            anchors.topMargin: Style.current.padding
            //% "Learn more"
            text: qsTrId("learn-more")
            font.pixelSize: 16
            color: Style.current.blue
            anchors.left: parent.left
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: Qt.openUrlExternally("https://status.im/tutorials/pairing.html")
            }
        }
    }

    StyledButton {
        id: syncAllBtn
        anchors.bottom: syncContainer.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        label: isSyncing ?
        //% "Syncing..."
        qsTrId("sync-in-progress") :
        //% "Sync all devices"
        qsTrId("sync-all-devices")
        disabled: isSyncing
        onClicked : {
            isSyncing = true;
            profileModel.syncAllDevices()
            // Currently we don't know how long it takes, so we just disable for 10s, to avoid spamming
            timer.setTimeout(function(){ 
                isSyncing = false
            }, 10000);
        }
    }

    Timer {
        id: timer
    }

}

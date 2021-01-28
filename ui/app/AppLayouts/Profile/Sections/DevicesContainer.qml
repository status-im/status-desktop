import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

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
        visible: !profileModel.devices.isSetup

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

        StatusButton {
            anchors.top: deviceNameTxt.bottom
            anchors.topMargin: 10
            anchors.right: deviceNameTxt.right
            //% "Continue"
            text: qsTrId("continue")
            enabled: deviceNameTxt.text !== ""
            onClicked : profileModel.devices.setName(deviceNameTxt.text.trim())
        }
    }

    Item {
        id: advertiseDeviceItem
        anchors.left: syncContainer.left
        anchors.leftMargin: Style.current.padding
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: syncContainer.right
        anchors.rightMargin: Style.current.padding
        visible: profileModel.devices.isSetup
        height: childrenRect.height

        Rectangle {
            id: advertiseDevice
            height: childrenRect.height
            width: 500
            anchors.left: parent.left
            anchors.right: parent.right
            color: Style.current.transparent

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
                onClicked: profileModel.devices.advertise()
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
                onClicked: appMain.openLink("https://status.im/user_guides/pairing_devices.html")
            }
        }
    }


    Item {
        id: deviceListItem
        anchors.left: syncContainer.left
        anchors.leftMargin: Style.current.padding
        anchors.top: advertiseDeviceItem.bottom
        anchors.topMargin: Style.current.padding * 2
        anchors.bottom: syncAllBtn.top
        anchors.bottomMargin: Style.current.padding
        anchors.right: syncContainer.right
        anchors.rightMargin: Style.current.padding
        visible: profileModel.devices.isSetup


        StyledText {
            id: deviceListLbl
            //% "Paired devices"
            text: qsTrId("paired-devices")
            font.pixelSize: 16
            font.weight: Font.Bold
        }

        ListView {
            id: listView
            anchors.bottom: parent.bottom
            anchors.top: deviceListLbl.bottom
            anchors.topMargin: Style.current.padding
            spacing: 5
            anchors.right: parent.right
            anchors.left: parent.left
            delegate: Item {
                height: childrenRect.height
                SVGImage {
                    id: enabledIcon
                    source: "/app/img/" + (devicePairedSwitch.checked ? "messageActive.svg" : "message.svg")
                    height: 24
                    width: 24
                }
                StyledText {
                    id: deviceItemLbl
                    text: {
                        let deviceId = model.installationId.split("-")[0].substr(0, 5)
                        //% "No info"
                        //% "you"
                        let labelText = `${model.name || qsTrId("pairing-no-info")} (${model.isUserDevice ? qsTrId("you") + ", ": ""}${deviceId})`;
                        return labelText;
                    }
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    anchors.left: enabledIcon.right
                    anchors.leftMargin: Style.current.padding
                }
                StatusSwitch { 
                    id: devicePairedSwitch
                    visible: !model.isUserDevice
                    checked: model.isEnabled 
                    anchors.left: deviceItemLbl.right
                    anchors.leftMargin: Style.current.padding
                    anchors.top: deviceItemLbl.top
                    onClicked: profileModel.devices.enableInstallation(model.installationId, devicePairedSwitch)
                }
            }
            model: profileModel.devices.list
        }
    }

    StatusButton {
        id: syncAllBtn
        anchors.bottom: syncContainer.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: isSyncing ?
        //% "Syncing..."
        qsTrId("sync-in-progress") :
        //% "Sync all devices"
        qsTrId("sync-all-devices")
        enabled: !isSyncing
        onClicked : {
            isSyncing = true;
            profileModel.devices.syncAll()
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

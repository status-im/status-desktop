import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

SettingsContentBase {
    id: root

    property DevicesStore devicesStore

    property bool isSyncing: false

    Item {
        width: root.contentWidth
        height: parent.height

        Item {
            id: firstTimeSetup
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            visible: !root.devicesStore.isDeviceSetup
            height: visible ? childrenRect.height : 0

            StatusBaseText {
                id: deviceNameLbl
                //% "Please set a name for your device."
                text: qsTrId("pairing-please-set-a-name")
                font.pixelSize: Style.current.secondaryTextFontSize
                color: Theme.palette.directColor1
            }

            Input {
                id: deviceNameTxt
                //% "Specify a name"
                placeholderText: qsTrId("specify-name")
                anchors.top: deviceNameLbl.bottom
                anchors.topMargin: Style.current.padding
            }

            // TODO: replace with StatusQ component
            StatusButton {
                anchors.top: deviceNameTxt.bottom
                anchors.topMargin: Style.dp(10)
                anchors.right: deviceNameTxt.right
                //% "Continue"
                text: qsTrId("continue")
                enabled: deviceNameTxt.text !== ""
                onClicked : root.devicesStore.setName(deviceNameTxt.text.trim())
            }
        }

        Item {
            id: advertiseDeviceItem
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: firstTimeSetup.visible ? firstTimeSetup.bottom : parent.top
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            visible: root.devicesStore.isDeviceSetup
            height: visible ? childrenRect.height : 0

            Rectangle {
                id: advertiseDevice
                height: childrenRect.height
                width: Style.dp(500)
                anchors.left: parent.left
                anchors.right: parent.right
                color: Style.current.transparent

                SVGImage {
                    id: advertiseImg
                    height: Style.dp(32)
                    width: Style.dp(32)
                    anchors.left: parent.left
                    fillMode: Image.PreserveAspectFit
                    source: Style.svg("messageActive")
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Style.current.blue
                    }
                }

                StatusBaseText {
                    id: advertiseDeviceTitle
                    //% "Advertise device"
                    text: qsTrId("pair-this-device")
                    font.pixelSize: Style.dp(18)
                    font.weight: Font.Bold
                    color: Theme.palette.primaryColor1
                    anchors.left: advertiseImg.right
                    anchors.leftMargin: Style.current.padding
                }

                StatusBaseText {
                    id: advertiseDeviceDesk
                    //% "Pair your devices to sync contacts and chats between them"
                    text: qsTrId("pair-this-device-description")
                    font.pixelSize: Style.current.secondaryTextFontSize
                    anchors.top: advertiseDeviceTitle.bottom
                    anchors.topMargin: Style.dp(6)
                    anchors.left: advertiseImg.right
                    anchors.leftMargin: Style.current.padding
                    color: Theme.palette.directColor1
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: root.devicesStore.advertise()
                }
            }

            StatusBaseText {
                anchors.top: advertiseDevice.bottom
                anchors.topMargin: Style.current.padding
                //% "Learn more"
                text: qsTrId("learn-more")
                font.pixelSize: Style.dp(16)
                color: Theme.palette.primaryColor1
                anchors.left: parent.left
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: Global.openLink("https://status.im/user_guides/pairing_devices.html")
                }
            }
        }

        Item {
            id: deviceListItem
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.top: advertiseDeviceItem.visible ? advertiseDeviceItem.bottom : parent.top
            anchors.topMargin: Style.current.padding * 2
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            height: childrenRect.height
            visible: root.devicesStore.isDeviceSetup

            StatusBaseText {
                id: deviceListLbl
                //% "Paired devices"
                text: qsTrId("paired-devices")
                font.pixelSize: Style.dp(16)
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }

            ListView {
                id: listView
                anchors.top: deviceListLbl.bottom
                anchors.topMargin: Style.current.padding
                // This is a placeholder fix to the display. This whole page will be redesigned
                height: Style.dp(300)
                spacing: Style.dp(5)
                width: parent.width
                // TODO: replace with StatusQ component
                delegate: Item {
                    height: childrenRect.height
                    SVGImage {
                        id: enabledIcon
                        source: Style.svg("messageActive")
                        height: Style.dp(24)
                        width: Style.dp(24)
                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: devicePairedSwitch.checked ? Style.current.blue : Style.current.darkGrey
                        }
                    }
                    StatusBaseText {
                        id: deviceItemLbl
                        text: {
                            let deviceId = model.installationId.split("-")[0].substr(0, 5)
                            //% "No info"
                            let labelText = `${model.name || qsTrId("pairing-no-info")} ` +
                                //% "you"
                                `(${model.isCurrentDevice ? qsTrId("you") + ", ": ""}${deviceId})`;
                            return labelText;
                        }
                        elide: Text.ElideRight
                        font.pixelSize: Style.current.secondaryTextFontSize
                        anchors.left: enabledIcon.right
                        anchors.leftMargin: Style.current.padding
                        color: Theme.palette.directColor1
                    }
                    StatusSwitch {
                        id: devicePairedSwitch
                        visible: !model.isCurrentDevice
                        checked: model.enabled
                        anchors.left: deviceItemLbl.right
                        anchors.leftMargin: Style.current.padding
                        anchors.top: deviceItemLbl.top
                        onClicked: root.devicesStore.enableDevice(model.installationId, devicePairedSwitch)
                    }
                }
                model: root.devicesStore.devicesModel
            }
            
            StatusButton {
                id: syncAllBtn
                anchors.top: listView.bottom
                anchors.topMargin: Style.current.padding
                // anchors.bottom: parent.bottom
                // anchors.bottomMargin: Style.current.padding
                anchors.horizontalCenter: listView.horizontalCenter

                text: isSyncing ?
                        //% "Syncing..."
                        qsTrId("sync-in-progress") :
                        //% "Sync all devices"
                        qsTrId("sync-all-devices")
                enabled: !isSyncing
                onClicked : {
                    isSyncing = true;
                    root.devicesStore.syncAll()
                    // Currently we don't know how long it takes, so we just disable for 10s, to avoid spamming
                    timer.setTimeout(function(){
                        isSyncing = false
                    }, 10000);
                }
            }
        }

        Timer {
            id: timer
        }
    }
}

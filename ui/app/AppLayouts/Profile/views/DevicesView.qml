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

    Component.onCompleted: {
        root.devicesStore.loadDevices()
    }

    Column {
        width: root.contentWidth
        height: !!parent ? parent.height : 0
        spacing: Style.current.padding

        Item {
            id: firstTimeSetup
            width: parent.width
            visible: !root.devicesStore.isDeviceSetup
            height: visible ? childrenRect.height : 0

            StatusBaseText {
                id: deviceNameLbl
                text: qsTr("Please set a name for your device.")
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            Input {
                id: deviceNameTxt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: deviceNameLbl.bottom
                anchors.topMargin: Style.current.padding
                placeholderText: qsTr("Specify a name")
            }

            // TODO: replace with StatusQ component
            StatusButton {
                anchors.top: deviceNameTxt.bottom
                anchors.topMargin: 10
                anchors.right: deviceNameTxt.right
                text: qsTr("Continue")
                enabled: deviceNameTxt.text !== ""
                onClicked : root.devicesStore.setName(deviceNameTxt.text.trim())
            }
        }

        Item {
            id: advertiseDeviceItem
            width: parent.width
            visible: root.devicesStore.isDeviceSetup
            height: visible ? advertiseDevice.height + learnMoreText.height + Style.current.padding : 0

            Item {
                id: advertiseDevice
                height: childrenRect.height
                width: 500

                SVGImage {
                    id: advertiseImg
                    height: 32
                    width: 32
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
                    text: qsTr("Advertise device")
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: Theme.palette.primaryColor1
                    anchors.left: advertiseImg.right
                    anchors.leftMargin: Style.current.padding
                }

                StatusBaseText {
                    id: advertiseDeviceDesk
                    text: qsTr("Pair your devices to sync contacts and chats between them")
                    font.pixelSize: 14
                    anchors.top: advertiseDeviceTitle.bottom
                    anchors.topMargin: 6
                    anchors.left: advertiseImg.right
                    anchors.leftMargin: Style.current.padding
                    color: Theme.palette.directColor1
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: advertiseDevice
                onClicked: root.devicesStore.advertise()
            }

            StatusBaseText {
                id: learnMoreText
                anchors.top: advertiseDevice.bottom
                anchors.topMargin: Style.current.padding
                text: qsTr("Learn more")
                font.pixelSize: 16
                color: Theme.palette.primaryColor1
                anchors.left: parent.left
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: Global.openLink("https://status.im/user_guides/pairing_devices.html")
                }
            }
        }

        StatusBaseText {
            visible: root.devicesStore.devicesModule.devicesLoading
            text: qsTr("Loading devices...")
        }

        StatusBaseText {
            visible: root.devicesStore.devicesModule.devicesLoadingError
            text: qsTr("Error loading devices. Please try again later.")
        }

        Item {
            id: deviceListItem
            width: parent.width
            height: childrenRect.height
            visible: !root.devicesStore.devicesModule.devicesLoading &&
                !root.devicesStore.devicesModule.devicesLoadingError &&
                root.devicesStore.isDeviceSetup


            StatusBaseText {
                id: deviceListLbl
                text: qsTr("Paired devices")
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }

            StatusListView {
                id: listView
                anchors.top: deviceListLbl.bottom
                anchors.topMargin: Style.current.padding
                // This is a placeholder fix to the display. This whole page will be redesigned
                height: 300
                spacing: 5
                width: parent.width
                model: root.devicesStore.devicesModel
                // TODO: replace with StatusQ component
                delegate: Item {
                    height: childrenRect.height
                    SVGImage {
                        id: enabledIcon
                        source: Style.svg("messageActive")
                        height: 24
                        width: 24
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
                            let labelText = `${model.name || qsTr("No info")} ` +
                                `(${model.isCurrentDevice ? qsTr("you") + ", ": ""}${deviceId})`;
                            return labelText;
                        }
                        elide: Text.ElideRight
                        font.pixelSize: 14
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
            }
            
            StatusButton {
                id: syncAllBtn
                anchors.top: listView.bottom
                anchors.topMargin: Style.current.padding
                // anchors.bottom: parent.bottom
                // anchors.bottomMargin: Style.current.padding
                anchors.horizontalCenter: listView.horizontalCenter

                text: isSyncing ?
                        qsTr("Syncing...") :
                        qsTr("Sync all devices")
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

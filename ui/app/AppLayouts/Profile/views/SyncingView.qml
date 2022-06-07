import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

SettingsContentBase {
    id: root

    property DevicesStore devicesStore

    property bool isSyncing: false

    /*

        Design questions:
            1. Should any device be "renameable"?
            2. Presonalize device: should the only be limited amoud of colors or any color available?
            3. Advertise - removing?
            4. Where is "Enable device"?
            5. Max device name?

        Backend questions:
            1. List of device properties
            8. How do I add more properties to device? Like color/emoji/...
            2. List of device types (macosx/...)
            3. Sync a single device
            4. Sync duration
            5. What is "enable device"?
            6. How do i now if device is online?
            7. What is "duration" property?


        Filling the specs:
            1. Why are there no specs merged?
            2. Where do I put my specs?
            3. What should/must be in the specs?
            4. Is there a guide on writing those?

      */

    ColumnLayout {
        width: root.contentWidth
        height: parent.height
        spacing: Style.current.padding

        QtObject {
            id: d

            /*
                Device INFO:
                    id: "abcdabcd-1234-5678-9012-12a34b5cd678",
                    identity: ""
                    version: 1
                    enabled: true
                    timestamp: 0
                    metadata:
                        name: "MacBook-1"
                        deviceType: "macosx"
                        fcmToken: ""
            */

            property bool deviceHasColor: false
            property color deviceColor: "black" // TODO: move to backend
            property color effectiveDeviceColor: d.deviceHasColor ? d.deviceColor : Theme.palette.baseColor2

            function personalizeDevice(model) {
                Global.openPopup(personalizeDevicePopup, {
                                     "deviceModel": model,
                                 })
            }
        }

        ColumnLayout {
            id: firstTimeSetup
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            // visible: !root.devicesStore.isDeviceSetup
            spacing: Style.current.padding

            StatusInput {
                id: deviceNameTxt
                Layout.fillWidth: true
                label: qsTr("Please set a name for your device")
                input.placeholderText: qsTr("Specify a name")
            }

            StatusButton {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Continue")
                enabled: deviceNameTxt.text !== ""
                onClicked : root.devicesStore.setName(deviceNameTxt.text.trim())
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            // This is a placeholder fix to the display. This whole page will be redesigned
            height: 300
            spacing: Style.current.padding

            model: root.devicesStore.devicesModel

            delegate: StatusListItem {
                width: ListView.view.width
                title: model.name || qsTr("No device name")
                subTitle: {
                    const deviceId = model.installationId.split("-")[0].substr(0, 5)
                    `(${model.isCurrentDevice ? qsTrId("This device") + ", ": ""}${deviceId})`
                }
                icon.name: "desktop"
                icon.emoji: "😁"
                icon.color: d.deviceColor
                icon.letterSize: 14
                icon.isLetterIdenticon: true
                label: "Next back up in 4 hours"
                components: [
                    StatusButton {
                        text: "Sync now"
                        size: StatusBaseButton.Size.Small
                    },
                    StatusFlatButton {
                        height: parent.height
                        icon.name: "chevron-down"
                        icon.rotation: 270
                        color: Theme.palette.baseColor1
                        onClicked: d.personalizeDevice(model)
                    }
                ]
            }
        }


        Component {
            id: personalizeDevicePopup

            StatusModal {
                id: personalizeDeviceModal

                property var deviceModel

                anchors.centerIn: parent
                header.title: qsTr("Personalize %1").arg(deviceModel.name)

                padding: 16

                rightButtons: [
                    StatusButton {
                        text: "Done"
                        enabled: nameInput.text !== ""
                        onClicked : {
                            d.deviceColor = colorDialog.selectedColor
                            d.deviceHasColor = colorDialog.colorIsSelected
                            root.devicesStore.setName(nameInput.text.trim())
                            personalizeDeviceModal.close();
                        }
                    }
                ]

                ColumnLayout {

                    StatusInput {
                        id: nameInput
                       Layout.fillWidth: true
//                        label: qsTr("Device name")
//                        charLimit: popup.maxChannelNameLength
//                        input.placeholderText: qsTr("Name the device")
//                        input.onTextChanged: {
//                            input.text = Utils.convertSpacesToDashesAndUpperToLowerCase(input.text);
//                            input.cursorPosition = input.text.length
//                            if (popup.channelEmoji === "") {
//                                input.letterIconName = text;
//                            }
//                        }
                        input.icon.color: colorDialog.effectiveColor
                        input.leftPadding: 16
                        input.rightComponent: StatusRoundButton {
                            implicitWidth: 20
                            implicitHeight: 20
                            icon.width: implicitWidth
                            icon.height: implicitHeight
                            icon.name: "smiley"
                            onClicked: {
                                popup.emojiPopupOpened = true;
                                popup.emojiPopup.open();
                                popup.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
                                popup.emojiPopup.x = popup.width - 2 * Style.current.xlPadding;
                                popup.emojiPopup.y = popup.y + nameInput.height + 2 * Style.current.xlPadding;
                            }
                        }
                    }

                    StatusPickerButton {
                        Layout.fillWidth: true
                        bgColor: colorDialog.effectiveColor
                        contentColor: colorDialog.colorIsSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
                        text: colorDialog.colorIsSelected ? colorDialog.selectedColor.toString().toUpperCase() : qsTr("Pick a color")
                        onClicked: {
                            colorDialog.open();
                        }
                    }

                    StatusColorDialog {
                        id: colorDialog
                        Layout.fillWidth: true
                        anchors.centerIn: parent
                        property bool colorIsSelected
                        property color selectedColor
                        property color effectiveColor: colorIsSelected.colorIsSelected ? colorIsSelected.selectedColor : Theme.palette.baseColor2
                        onAccepted: {
                            selectedColor = color
                            colorIsSelected = true
                        }
                    }
                }

            }
        }


        //        Item {
        //            id: deviceListItem
        //            anchors.left: parent.left
        //            anchors.leftMargin: Style.current.padding
        //            anchors.top: advertiseDeviceItem.visible ? advertiseDeviceItem.bottom : parent.top
        //            anchors.topMargin: Style.current.padding * 2
        //            anchors.right: parent.right
        //            anchors.rightMargin: Style.current.padding
        //            height: childrenRect.height
        //            visible: root.devicesStore.isDeviceSetup

        //            StatusBaseText {
        //                id: deviceListLbl
        //                //% "Paired devices"
        //                text: qsTrId("paired-devices")
        //                font.pixelSize: 16
        //                font.weight: Font.Bold
        //                color: Theme.palette.directColor1
        //            }


        //            StatusButton {
        //                id: syncAllBtn
        //                anchors.top: listView.bottom
        //                anchors.topMargin: Style.current.padding
        //                // anchors.bottom: parent.bottom
        //                // anchors.bottomMargin: Style.current.padding
        //                anchors.horizontalCenter: listView.horizontalCenter

        //                text: isSyncing ?
        //                        //% "Syncing..."
        //                        qsTrId("sync-in-progress") :
        //                        //% "Sync all devices"
        //                        qsTrId("sync-all-devices")
        //                enabled: !isSyncing
        //                onClicked : {
        //                    isSyncing = true;
        //                    root.devicesStore.syncAll()
        //                    // Currently we don't know how long it takes, so we just disable for 10s, to avoid spamming
        //                    timer.setTimeout(function(){
        //                        isSyncing = false
        //                    }, 10000);
        //                }
        //            }
        //        }

        //        Timer {
        //            id: timer
        //        }
    }
}

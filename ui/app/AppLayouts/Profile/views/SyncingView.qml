import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.panels 1.0
import shared.controls 1.0

import "../stores"

SettingsContentBase {
    id: root

    property DevicesStore devicesStore
    property var emojiPopup

    property bool isSyncing: false

    /*

        Design questions:
            1. Should any device be "renamable"?
            2. Personalize device: should we use a "Colour button" instead of limited colors?
            3. Advertise - removing?
            4. Where is "Enable device"? Or something like "remove sync with device".
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
            property string deviceEmoji: "" // TODO: move to backend
            property color effectiveDeviceColor: d.deviceHasColor ? d.deviceColor : Theme.palette.baseColor2

            property bool emojiPopupOpened: false

            readonly property var instructionsModel: [
                                        qsTr("Verify your login with password or KeyCard"),
                                        qsTr("Reveal a temporary QR and Sync Code") + "*",
                                        qsTr("Share that information with your new device"),
                                    ]

            readonly property var daysOfWeek: [
                qsTr("Sunday"),
                qsTr("Monday"),
                qsTr("Tuesday"),
                qsTr("Wednesday"),
                qsTr("Thursday"),
                qsTr("Friday"),
                qsTr("Saturday"),
            ]

            function personalizeDevice(model) {
                Global.openPopup(personalizeDevicePopup, {
                                     "deviceModel": model,
                                 })
            }

            function setupSyncing() {

            }
        }

        Connections {
            enabled: d.emojiPopupOpened
            target: root.emojiPopup

            onEmojiSelected: function (emojiText, atCursor) {
    //            contentItem.channelName.input.icon.isLetterIdenticon = false;
    //            scrollView.channelName.input.icon.emoji = emojiText
                d.deviceEmoji = emojiText
                console.log("Selected emoji: ", emojiText)
            }
            onClosed: {
                d.emojiPopupOpened = false
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Devices")
            font.pixelSize: 15
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.topMargin: 17
            Layout.bottomMargin: 17

            implicitHeight: contentHeight

//            Layout.maximumHeight: 400

//            contentWidth: contentItem.childrenRect.width
//            contentHeight: contentItem.childrenRect.height

            spacing: Style.current.padding
            model: root.devicesStore.devicesModel

            delegate: StatusListItem {

                readonly property var lastSyncDate: new Date(timestamp)
                readonly property int millisecondsFromSync: lastSyncDate - Date.now()
                readonly property int secondsFromSync: millisecondsFromSync / 1000
                readonly property int minutesFromSync: secondsFromSync / 60
                readonly property int daysFromSync: new Date().getDay() - lastSyncDate.getDay()

                width: ListView.view.width
                title: model.name || qsTr("No device name")

                subTitle: {
                    if (model.isCurrentDevice)
                        return qsTr("This device");

                    if (secondsFromSync <= 120)
                        return qsTr("Online now");

                    if (minutesFromSync <= 60)
                        return qsTr("Online %1 minutes ago").arg(minutesFromSync);

                    if (daysFromSync == 0)
                        return qsTr("Last seen earlier today");

                    if (daysFromSync == 1)
                        return qsTr("Last online yesterday");

                    if (daysFromSync <= 6)
                        return qsTr("Last online [%1]").arg(daysOfWeek[lastSyncDate.getDay()]);

                    return qsTr("Last online %1").arg(lastSyncDate.toLocaleDateString(Qt.locale()))

                }

                icon.name: !!d.deviceEmoji ? "" : "desktop"
                icon.emoji: d.deviceEmoji
                icon.background.color: d.effectiveDeviceColor
                icon.isLetterIdenticon: false
                // label: qsTr("Next back up in %1 hours")

                components: [
                    StatusButton {
                        text: qsTr("Setup syncing")
                        size: StatusBaseButton.Size.Small
                        onClicked: d.setupSyncing()
                    },
                    StatusIcon {
                        height: parent.height
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]

                onClicked: d.personalizeDevice(model)
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 17

            implicitWidth: instructionsLayout.implicitWidth
                           + instructionsLayout.anchors.leftMargin
                           + instructionsLayout.anchors.rightMargin

            implicitHeight: instructionsLayout.implicitHeight
                            + instructionsLayout.anchors.topMargin
                            + instructionsLayout.anchors.bottomMargin

            color: Theme.palette.primaryColor3
            radius: 8

            ColumnLayout {
                id: instructionsLayout

                anchors {
                    fill: parent
                    topMargin: 24
                    bottomMargin: 24
                    leftMargin: 16
                    rightMargin: 16
                }

                spacing: 17

                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.topMargin: -8
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.palette.primaryColor1
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    text: qsTr("Sync a New Device")
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    text: qsTr("You own your data. Sync it among your devices.")
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    rows: d.instructionsModel.length
                    flow: GridLayout.TopToBottom

                    Repeater {
                        model: d.instructionsModel

                        StatusBaseText {
                            Layout.alignment: Qt.AlignVCenter
                            color: Theme.palette.baseColor1
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            text: index + 1
                        }
                    }

                    Repeater {
                        model: d.instructionsModel

                        StatusBaseText {
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            color: Theme.palette.directColor1
                            font.pixelSize: 15
                            text: modelData
                        }
                    }
                }

                StatusButton {
                    type: StatusRou1ndButton.Type.Secondary
                    Layout.alignment: Qt.AlignHCenter
                    normalColor: Theme.palette.primaryColor1
                    hoverColor: Theme.palette.miscColor1;
                    textColor: Theme.palette.indirectColor1
                    font.weight: Font.Medium
                    text: qsTr("Setup Syncing")
                    onClicked: d.setupSyncing()
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.palette.baseColor1
                    font.pixelSize: 13
                    text: "* " + qsTr("This is best done in private. The code will grant access to your profile.")
                }
            }
        }

        StatusFlatButton {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
            font.weight: Font.Medium
            text: qsTr("Enter Sync Code")
        }

        StatusFlatButton {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
            font.weight: Font.Medium
            text: qsTr("Scan Sync Code")
        }

        Component {
            id: personalizeDevicePopup

            StatusModal {
                id: personalizeDeviceModal

                property var deviceModel

                anchors.centerIn: parent
                header.title: qsTr("Personalize %1").arg(deviceModel.name)

                onOpened: {
                    nameInput.text = deviceModel.name
                }

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

                contentItem: ColumnLayout {

                    StatusInput {
                        id: nameInput
                        Layout.fillWidth: true
                        label: qsTr("Device name")
                        //                        charLimit: popup.maxChannelNameLength
                        //                        input.placeholderText: qsTr("Name the device")
                        //                        input.onTextChanged: {
                        //                            input.text = Utils.convertSpacesToDashesAndUpperToLowerCase(input.text);
                        //                            input.cursorPosition = input.text.length
                        //                            if (popup.channelEmoji === "") {
                        //                                input.letterIconName = text;
                        //                            }
                        //                        }
                        input.icon.name: !!d.deviceEmoji ? "" : "desktop"
                        input.icon.emoji: d.deviceEmoji
                        input.icon.background.color: colorDialog.effectiveColor
                        input.leftPadding: 16
                        input.rightComponent: StatusRoundButton {
                            implicitWidth: 20
                            implicitHeight: 20
                            icon.width: implicitWidth
                            icon.height: implicitHeight
                            icon.name: "smiley"
                            onClicked: {
                                d.emojiPopupOpened = true;
                                root.emojiPopup.open();
                                root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
                                root.emojiPopup.x = root.width - 2 * Style.current.xlPadding;
                                root.emojiPopup.y = root.y + nameInput.height + 2 * Style.current.xlPadding;
                            }
                        }
                    }

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: qsTr("Channel colour")
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    StatusColorSelectorGrid {

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
                        anchors.centerIn: parent
                        property bool colorIsSelected
                        property color selectedColor
                        property color effectiveColor: colorIsSelected ? selectedColor : Theme.palette.baseColor2
                        onOpened: {
                            if (colorIsSelected) {
                                color = d.deviceColor;
                                colorIsSelected = false;
                            }
                        }
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

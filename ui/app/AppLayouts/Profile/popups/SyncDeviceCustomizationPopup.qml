import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

import "../stores"

StatusModal {
    id: root

    property DevicesStore devicesStore
    property var deviceModel
    property var emojiPopup

    readonly property string deviceName: d.deviceName
    readonly property string deviceEmojiId: d.deviceEmojiId
    readonly property int deviceColorIndex: d.deviceColorIndex

    header.title: qsTr("Personalize %1").arg(deviceModel.name)
    width: implicitWidth
    padding: 16

    QtObject {
        id: d
        property bool emojiPopupOpened: false
        property string deviceName: ""
        property string deviceEmojiId: ""
        property int deviceColorIndex: 0
    }

    Connections {
        enabled: d.emojiPopupOpened
        target: root.emojiPopup

        onEmojiSelected: function (emojiText, atCursor) {
//            contentItem.channelName.input.icon.isLetterIdenticon = false;
//            scrollView.channelName.input.icon.emoji = emojiText
            d.deviceEmojiId = emojiText
            console.log("Selected emoji: ", emojiText)
        }
        onClosed: {
            d.emojiPopupOpened = false
        }
    }

    onOpened: {
        colorGrid.selectedColorIndex = d.deviceColorIndex
        nameInput.text = deviceModel.name
    }

    rightButtons: [
        StatusButton {
            text: "Done"
            enabled: nameInput.text !== ""
            onClicked : {
                d.deviceColorIndex = colorGrid.selectedColorIndex
                root.devicesStore.setName(nameInput.text.trim())
                root.close();
            }
        }
    ]

    contentItem: ColumnLayout {

        StatusInput {
            id: nameInput
            Layout.fillWidth: true
            label: qsTr("Device name")
            input.icon.name: !!d.deviceEmojiId ? "" : "desktop"
            input.icon.emoji: d.deviceEmojiId
            input.icon.color: input.icon.isLetterIdenticon && colorGrid.selectedColorIndex >= 0 ? colorGrid.selectedColor : Theme.palette.primaryColor1
            input.icon.background.color: colorGrid.selectedColorIndex >= 0 ? colorGrid.selectedColor : Theme.palette.primaryColor3
            input.icon.isLetterIdenticon: !!d.deviceEmojiId
            input.isIconSelectable: true
            input.leftPadding: 16
            onIconClicked: {
                d.emojiPopupOpened = true;
                root.emojiPopup.open();
                root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
                root.emojiPopup.x = root.width;
                root.emojiPopup.y = root.y + nameInput.height + 32;
            }
        }

        StatusColorSelectorGrid {
            id: colorGrid
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 42
            Layout.bottomMargin: 42
            title.text: qsTr("Colour")
            title.font.weight: Font.Medium
            title.font.pixelSize: 13
            title.color: Theme.palette.baseColor1
        }
    }
}

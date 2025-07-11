import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import utils
import shared
import shared.panels

import "../helpers/channelList.js" as ChannelJSON
import "../controls"

Repeater {
    id: sectionRepeater
    model: ChannelJSON.categories
    signal suggestedMessageClicked(string channel)
    Item {
        anchors.top: index === 0 ? parent.top : parent.children[index - 1].bottom
        anchors.topMargin: index === 0 ? 0 : Theme.padding
        width: parent.width - Theme.padding
        height: childrenRect.height

        StyledText {
            id: sectionTitle
            text: modelData.name
            font.bold: true
            font.pixelSize: Theme.fontSize16
        }
        Flow {
            width: parent.width
            anchors.top: sectionTitle.bottom
            anchors.topMargin: Theme.smallPadding
            spacing: 10
            Repeater {
                model: modelData.channels
                SuggestedChannel {
                    channel: modelData
                    onClicked: {
                        suggestedMessageClicked(channel);
                    }
                }
            }
        }
    }
}

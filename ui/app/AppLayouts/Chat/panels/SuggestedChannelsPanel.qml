import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0

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

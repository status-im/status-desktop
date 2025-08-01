import QtQuick
import QtQuick.Controls

import StatusQ.Core.Theme

import shared.controls.chat

Pane {
    id: root

    layer.enabled: true
    layer.samples: 4
    background: Rectangle {
        color: Theme.palette.statusChatInput.secondaryBackgroundColor
    }

    LinkPreviewSettingsCard {
        id: previewMiniCard
        anchors.centerIn: parent
        onDismiss: ToolTip.show(qsTr("Link previews disabled for this message"), 1000)
        onEnableLinkPreviewForThisMessage: ToolTip.show(qsTr("Link previews enabled for this message"), 1000)
        onEnableLinkPreview: ToolTip.show(qsTr("Link previews enabled"), 1000)
        onDisableLinkPreview: ToolTip.show(qsTr("Link previews disabled"), 1000)
    }
}


//category: Controls

//https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=22341-184809&mode=design&t=91pnQgUZAqFJLcqM-0

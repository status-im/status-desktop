import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

RowLayout {
    id: root

    property bool joinCommunity: true // Otherwise it means join channel action

    property color color

    property string name
    property string channelName

    property string communityDesc
    property string channelDesc

    spacing: 30

    StatusChatInfoButton {
        id: headerInfoButton
        Layout.preferredHeight: parent.height
        Layout.minimumWidth: 100
        Layout.fillWidth: true
        title: root.joinCommunity ? root.name : root.channelName
        subTitle: root.joinCommunity ? root.communityDesc : root.channelDesc
        asset.color: root.color
        enabled: false
        type: StatusChatInfoButton.Type.CommunityChat
        layer.enabled: root.joinCommunity // Blured when joining community but not when entering channel
        layer.effect: fastBlur
    }

    RowLayout {
        Layout.preferredHeight: parent.height
        spacing: 10
        layer.enabled: true
        layer.effect: fastBlur

        StatusFlatRoundButton {
            id: search
            icon.name: "search"
            type: StatusFlatRoundButton.Type.Secondary
            enabled: false
        }

        StatusFlatRoundButton {
            icon.name: "group-chat"
            type: StatusFlatRoundButton.Type.Secondary
            enabled: false
        }

        StatusFlatRoundButton {
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary
            enabled: false
        }
    }

    Component {
        id: fastBlur

        FastBlur {
            radius: 32
            transparentBorder: true
        }
    }
}

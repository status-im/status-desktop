import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.views 1.0

import StatusQ.Layout 0.1

import utils 1.0
import shared.popups 1.0

StatusSectionLayout {
    id: root

    // General properties:
    property bool amISectionAdmin: false
    property bool openCreateChat: false
    property string name
    property string communityDesc
    property color color
    property string channelName
    property string channelDesc
    property bool joinCommunity: true // Otherwise it means join channel action

    // Blur view properties:
    property int membersCount
    property url image
    property var communityItemsModel
    property string chatDateTimeText
    property string listUsersText
    property var messagesModel

    signal infoButtonClicked
    signal adHocChatButtonClicked


    QtObject {
        id: d

        readonly property int blurryRadius: 32
    }

    headerContent: JoinCommunityHeaderPanel {
        joinCommunity: root.joinCommunity
        color: root.color
        name: root.name
        channelName: root.channelName
        communityDesc: root.communityDesc
        channelDesc: root.channelDesc
    }

    // Blur background:
    leftPanel: ColumnLayout {
        anchors.fill: parent

        ColumnHeaderPanel {
            Layout.fillWidth: true
            name: root.name
            membersCount: root.membersCount
            image: root.image
            color: root.color
            amISectionAdmin: root.amISectionAdmin
            openCreateChat: root.openCreateChat
            onInfoButtonClicked: if(root.amISectionAdmin) root.infoButtonClicked()
            onAdHocChatButtonClicked: root.adHocChatButtonClicked()
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Style.current.halfPadding
            layer.enabled: root.joinCommunity
            layer.effect: fastBlur

            Repeater {
                model: root.communityItemsModel
                delegate: StatusChatListItem {
                    enabled: false
                    name: model.name
                    asset.color: root.color
                    selected: model.selected
                    type: StatusChatListItem.Type.CommunityChat
                    notificationsCount: model.notificationsCount
                    hasUnreadMessages: model.hasUnreadMessages
                }
            }
        }

        Item {
            // filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // Blur background + Control node offline information content:
    centerPanel: ControlNodeOfflineCenterPanel {
        id: joinCommunityCenterPanel

        anchors.fill: parent
        name: root.name
        chatDateTimeText: root.chatDateTimeText
        listUsersText: root.listUsersText
        messagesModel: root.messagesModel
    }

    showRightPanel: false

    Component {
        id: fastBlur

        FastBlur {
            radius: d.blurryRadius
            transparentBorder: true
        }
    }
}

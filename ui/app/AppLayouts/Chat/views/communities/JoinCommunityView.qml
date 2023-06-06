import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Chat.panels.communities 1.0
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
    property string introMessage
    property string communityDesc
    property color color
    property string channelName
    property string channelDesc
    property bool joinCommunity: true // Otherwise it means join channel action
    property int accessType
    property bool isInvitationPending: false

    // Permission overlay view properties:
    property bool requirementsMet: true
    property bool isJoinRequestRejected: false
    property bool requiresRequest: false
    property alias loginType: overlayPanel.loginType

    property var communityHoldingsModel
    property var viewOnlyHoldingsModel
    property var viewAndPostHoldingsModel
    property var moderateHoldingsModel
    property var assetsModel
    property var collectiblesModel

    // Blur view properties:
    property int membersCount
    property url image
    property var communityItemsModel
    property string chatDateTimeText
    property string listUsersText
    property var messagesModel

    signal infoButtonClicked
    signal adHocChatButtonClicked
    signal revealAddressClicked
    signal invitationPendingClicked
    signal joined
    signal cancelMembershipRequest

    function openJoinCommunityDialog() {
        joinCommunityDialog.open()
    }

    QtObject {
        id: d

        readonly property int blurryRadius: 32
    }

    // Blur background:
    headerContent: RowLayout {
        anchors.fill: parent
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
    }

    // Blur background:
    leftPanel: ColumnLayout {
        anchors.fill: parent

        CommunityColumnHeaderPanel {
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
            layer.enabled: true
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

    // Blur background + Permissions base information content:
    centerPanel: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Blur background:
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(centralPanelData.implicitHeight, parent.height - overlayPanel.implicitHeight)

            ColumnLayout {
                id: centralPanelData
                width: parent.width
                layer.enabled: true
                layer.effect: fastBlur

                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 30
                    Layout.bottomMargin: 30
                    text: root.chatDateTimeText
                    font.pixelSize: 13
                    color: Theme.palette.baseColor1
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter

                    StatusBaseText {
                        text: root.listUsersText
                        font.pixelSize: 13
                    }

                    StatusBaseText {
                        text: qsTr("joined the channel")
                        font.pixelSize: 13
                        color: Theme.palette.baseColor1
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height + spacing
                    Layout.topMargin: 16
                    spacing: 16
                    model: root.messagesModel
                    delegate: StatusMessage {
                        width: ListView.view.width
                        timestamp: model.timestamp
                        enabled: false
                        messageDetails: StatusMessageDetails {
                            messageText: model.message
                            contentType: model.contentType
                            sender.displayName: model.senderDisplayName
                            sender.isContact: model.isContact
                            sender.trustIndicator: model.trustIndicator
                            sender.profileImage: StatusProfileImageSettings {
                                width: 40
                                height: 40
                                name: model.profileImage || ""
                                colorId: model.colorId
                            }
                        }
                    }
                }
            }
        }

        // Permissions base information content:
        Rectangle {
            id: panelBase

            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
            gradient: Gradient {
                GradientStop {
                    position: 0.000
                    color: "transparent"
                }
                GradientStop {
                    position: 0.180
                    color: panelBase.color
                }
            }

            StatusScrollView {
                anchors.fill: parent
                padding: 0

                Item {
                    implicitHeight: Math.max(overlayPanel.implicitHeight, panelBase.height)
                    implicitWidth: Math.max(overlayPanel.implicitWidth, panelBase.width)

                    JoinPermissionsOverlayPanel {
                        id: overlayPanel

                        anchors.centerIn: parent

                        topPadding: 2 * bottomPadding
                        joinCommunity: root.joinCommunity
                        requirementsMet: root.requirementsMet
                        isInvitationPending: root.isInvitationPending
                        isJoinRequestRejected: root.isJoinRequestRejected
                        requiresRequest: root.requiresRequest
                        communityName: root.name
                        communityHoldingsModel: root.communityHoldingsModel
                        channelName: root.channelName

                        viewOnlyHoldingsModel: root.viewOnlyHoldingsModel
                        viewAndPostHoldingsModel: root.viewAndPostHoldingsModel
                        moderateHoldingsModel: root.moderateHoldingsModel
                        assetsModel: root.assetsModel
                        collectiblesModel: root.collectiblesModel

                        onRevealAddressClicked: root.revealAddressClicked()
                        onInvitationPendingClicked: root.invitationPendingClicked()
                    }
                }
            }
        }
    }
    showRightPanel: false

    Component {
        id: fastBlur

        FastBlur {
            radius: d.blurryRadius
            transparentBorder: true
        }
    }

    CommunityIntroDialog {
        id: joinCommunityDialog

        name: root.name
        introMessage: root.introMessage
        imageSrc: root.image
        accessType: root.accessType
        isInvitationPending: root.isInvitationPending

        onJoined: root.joined()
        onCancelMembershipRequest: root.cancelMembershipRequest()
    }
}

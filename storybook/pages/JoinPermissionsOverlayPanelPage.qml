import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.panels.communities 1.0


import utils 1.0

SplitView {

    QtObject {
        id: d

        property string name: "Uniswap"
        property string channelName: "#vip"
        property bool joinCommunity: true // Otherwise, enter channel
        property bool requirementsMet: true
        property bool isInvitationPending: false
        property bool isJoinRequestRejected: false
        property bool requiresRequest: false
        property var communityHoldings: PermissionsModel.shortPermissionsModel
        property var viewOnlyHoldings: PermissionsModel.shortPermissionsModel
        property var viewAndPostHoldings: PermissionsModel.shortPermissionsModel
        property var moderateHoldings: PermissionsModel.shortPermissionsModel
    }

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true



        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                id: rect
                width: widthSlider.value
                height: heightSlider.value
                anchors.centerIn: parent
                color: Theme.palette.baseColor4

                StatusScrollView {
                    id: scroll
                    anchors.fill: parent
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                    contentHeight: content.height
                    contentWidth: content.width
                    padding: 0

                    Item {
                        id: content
                        height: Math.max(overlayPannel.implicitHeight, rect.height)
                        width: Math.max(overlayPannel.implicitWidth, rect.width)

                        JoinPermissionsOverlayPanel {
                            id: overlayPannel

                            anchors.centerIn: parent
                            joinCommunity: d.joinCommunity
                            requirementsMet: d.requirementsMet
                            isInvitationPending: d.isInvitationPending
                            isJoinRequestRejected: d.isJoinRequestRejected
                            requiresRequest: d.requiresRequest
                            communityName: d.name
                            communityHoldings: d.communityHoldings
                            channelName: d.channelName
                            viewOnlyHoldings: d.viewOnlyHoldings
                            viewAndPostHoldings: d.viewAndPostHoldings
                            moderateHoldings: d.moderateHoldings

                            onRevealAddressClicked: logs.logEvent("JoinPermissionsOverlayPanel::onRevealAddressClicked()")
                            onInvitationPendingClicked: logs.logEvent("JoinPermissionsOverlayPanel::onInvitationPendingClicked()")
                        }
                    }
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 250
            logsView.logText: logs.logText

            ColumnLayout {
                Row {
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Width:"
                    }

                    Slider {
                        id: widthSlider
                        value: 800
                        from: 350
                        to: 1000
                    }
                }

                Row {
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Height:"
                    }

                    Slider {
                        id: heightSlider
                        value: 500
                        from: 100
                        to: 1000
                    }
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: "Name"
                }
                TextField {
                    background: Rectangle { border.color: 'lightgrey' }
                    Layout.preferredWidth: 200
                    text: d.name
                    onTextChanged: d.name = text
                }
            }

            JoinCommunityPermissionsEditor {
                channelName: d.chanelName
                joinCommunity: d.joinCommunity
                requirementsMet: d.requirementsMet
                isInvitationPending: d.isInvitationPending
                isJoinRequestRejected: d.isJoinRequestRejected
                requiresRequest: d.requiresRequest

                onChannelNameChanged: d.channelName = channelName
                onJoinCommunityChanged: d.joinCommunity = joinCommunity
                onRequirementsMetChanged: d.requirementsMet = requirementsMet
                onIsInvitationPendingChanged: d.isInvitationPending = isInvitationPending
                onIsJoinRequestRejectedChanged: d.isJoinRequestRejected = isJoinRequestRejected
                onRequiresRequestChanged: d.requiresRequest = requiresRequest
                onCommunityHoldingsChanged: d.communityHoldings = communityHoldings
                onViewOnlyHoldingsChanged: d.viewOnlyHoldings = viewOnlyHoldings
                onViewAndPostHoldingsChanged: d.viewAndPostHoldings = viewAndPostHoldings
                onModerateHoldingsChanged: d.moderateHoldings = moderateHoldings
            }
        }
    }
}

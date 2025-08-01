import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import shared.panels
import shared.popups

import AppLayouts.Chat.stores as ChatStores

Control {
    id: root

    implicitWidth: d.invitedCommunity || d.loading ? 270 /*by design*/ : 0
    padding: 1

    property ChatStores.RootStore store
    property string communityId

    signal spectateCommunityRequested(string communityId)

    QtObject {
        id: d

        property var invitedCommunity

        readonly property string communityName:         !!d.invitedCommunity ? d.invitedCommunity.name : ""
        readonly property string communityDescription:  !!d.invitedCommunity ? d.invitedCommunity.description : ""
        readonly property string communityImage:        !!d.invitedCommunity ? d.invitedCommunity.image : ""
        readonly property string communityColor:        !!d.invitedCommunity ? d.invitedCommunity.color : ""
        readonly property int    communityNbMembers:    !!d.invitedCommunity ? d.invitedCommunity.nbMembers : 0
        readonly property bool   communityVerified:     false //!!d.invitedCommunity ? d.invitedCommunity.verified : false TODO: add this to the community object if we should support verified communities
        readonly property bool   communityJoined:       !!d.invitedCommunity ? d.invitedCommunity.joined : false
        readonly property bool   communitySpectated:    !!d.invitedCommunity ? d.invitedCommunity.spectated : false

        readonly property int margin: 12
        readonly property int radius: Theme.padding

        readonly property bool loading: !d.invitedCommunity

        function getCommunity() {
            try {
                const communityJson = root.store.getSectionByIdJson(communityId)

                if (!communityJson) {
                    // we don't have the shard info, so we will try to fetch it on waku
                    root.store.requestCommunityInfo(communityId, -1, -1)
                    return null
                }

                return JSON.parse(communityJson);
            } catch (e) {
                console.error("Error parsing community", e)
            }

            return null
        }

        function reevaluate() {
            invitedCommunity = getCommunity()
        }
    }

    Component.onCompleted: {
        d.reevaluate()
    }

    Connections {
        target: root.store.communitiesModuleInst
        function onCommunityChanged(communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
        function onCommunityAdded(communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    background: Rectangle {
        radius: d.radius
        color: Theme.palette.background
        border.color: Theme.palette.border
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        StatusBaseText {
            id: title

            Layout.fillWidth: true
            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            Layout.topMargin: 8
            Layout.bottomMargin: 8

            text: d.communityVerified ? qsTr("Verified community invitation") : qsTr("Community invitation")
            color: d.communityVerified ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            font.weight: Font.Medium
            font.pixelSize: Theme.additionalTextSize
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.separator
        }

        RowLayout {
            id: communityDescriptionLayout

            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            Layout.topMargin: 12
            Layout.bottomMargin: 12

            spacing: 12

            StatusSmartIdenticon {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                name: d.communityName

                asset {
                    width: 40
                    height: 40
                    name: d.communityImage
                    color: d.communityColor
                    isImage: true
                }

                visible: d.communityColor && d.communityName
            }

            ColumnLayout {
                spacing: 2

                StatusBaseText {
                    Layout.fillWidth: true
                    objectName: "communityName"
                    text: d.communityName
                    font.weight: Font.Bold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: Theme.secondaryAdditionalTextSize
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    objectName: "communityDescription"
                    text: d.communityDescription
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    objectName: "communityMembers"
                    text: qsTr("%n member(s)", "", d.communityNbMembers)
                    font.pixelSize: Theme.additionalTextSize
                    font.weight: Font.Medium
                    color: Theme.palette.baseColor1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.separator
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            clip: true

            StatusFlatButton {
                id: joinBtn
                width: parent.width
                height: (parent.height+d.radius)
                anchors.top: parent.top
                anchors.topMargin: -d.radius
                loading: d.loading
                radius: d.radius - 1 // We do -1, otherwise there's a gap between border and button
                contentItem: Item {
                    StatusBaseText {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: d.radius/2
                        visible: !joinBtn.loading
                        font: joinBtn.font
                        color: joinBtn.enabled ? joinBtn.textColor : joinBtn.disabledTextColor
                        text: qsTr("Go to Community")
                    }
                }

                onClicked: {
                    if (d.communityJoined || d.communitySpectated) {
                        root.store.setActiveCommunity(communityId)
                    } else {
                        root.spectateCommunityRequested(communityId)
                    }
                }
            }
        }
    }
}

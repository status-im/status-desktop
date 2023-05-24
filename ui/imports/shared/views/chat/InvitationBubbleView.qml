import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.panels 1.0
import shared.popups 1.0

Control {
    id: root

    implicitWidth: d.invitedCommunity || loading ? 270 /*by design*/ : 0
    padding: 1

    property var store
    property string communityId
    property bool loading: false

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
        readonly property int radius: 16

        function getCommunity() {
            try {
                const communityJson = root.store.getSectionByIdJson(communityId)

                if (!communityJson) {
                    root.store.requestCommunityInfo(communityId)
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
        color: Style.current.background
        border.color: Style.current.border
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
            font.pixelSize: 13
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Style.current.separator
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

                visible: !root.loading
            }

            ColumnLayout {
                spacing: 2

                StatusBaseText {
                    Layout.fillWidth: true

                    text: root.loading ? qsTr("Community data not loaded yet.") : d.communityName
                    font.weight: Font.Bold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 17
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true

                    text: root.loading ? qsTr("Please wait for the unfurl to show") : d.communityDescription
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true

                    text: root.loading ? "" : qsTr("%n member(s)", "", d.communityNbMembers)
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Theme.palette.baseColor1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Style.current.separator
        }

        StatusFlatButton {
            id: joinBtn

            Layout.fillWidth: true
            Layout.preferredHeight: 44

            text: qsTr("Go to Community")
            loading: root.loading
            radius: d.radius - 1 // We do -1, otherwise there's a gap between border and button

            onClicked: {
                if (d.communityJoined || d.communitySpectated) {
                    root.store.setActiveCommunity(communityId)
                } else {
                    root.store.spectateCommunity(communityId, userProfile.name)
                }
            }
        }
    }
}

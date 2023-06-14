import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

import "../panels"
import "../../Chat/popups/community"

SettingsContentBase {
    id: root

    property var profileSectionStore
    property var rootStore
    property var contactStore

    clip: true

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Import community")
        size: StatusBaseButton.Size.Small
        onClicked: Global.importCommunityPopupRequested()
    }

    Item {
        id: rootItem
        width: root.contentWidth
        height: childrenRect.height

        ColumnLayout {
            id: noCommunitiesLayout
            anchors.fill: parent
            visible: communitiesList.count === 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            Image {
                source: Style.png("settings/communities")
                mipmap: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.preferredWidth: 434
                Layout.preferredHeight: 213
                Layout.topMargin: 18
                cache: false
            }

            StatusBaseText {
                text: qsTr("Discover your Communities")
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 17
                Layout.topMargin: 35

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            }

            StatusBaseText {
                text: qsTr("Explore and see what communities are trending")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                font.pixelSize: 15
                Layout.topMargin: 8
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            }

            StatusButton {
                text: qsTr("Discover")
                Layout.topMargin: 16
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                onClicked: Global.changeAppSectionBySectionType(Constants.appSection.communitiesPortal)
            }
        }

        Column {
            id: rootLayout
            visible: !noCommunitiesLayout.visible
            width: parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: Style.current.padding

            StatusBaseText {
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                color: Theme.palette.baseColor1
                text: qsTr("Communities you've joined")
            }

            CommunitiesListPanel {
                id: communitiesList

                objectName: "CommunitiesView_communitiesListPanel"
                width: parent.width

                model: SortFilterProxyModel {
                    id: filteredModel

                    sourceModel: root.profileSectionStore.communitiesList
                    filters: [
                        ValueFilter {
                            roleName: "joined"
                            value: true
                        }
                    ]
                }

                onCloseCommunityClicked: {
                    root.profileSectionStore.communitiesProfileModule.leaveCommunity(communityId)
                }

                onLeaveCommunityClicked: {
                    Global.leaveCommunityRequested(community, communityId, outroMessage)
                }

                onSetCommunityMutedClicked: {
                    root.profileSectionStore.communitiesProfileModule.setCommunityMuted(communityId, muted)
                }

                onSetActiveCommunityClicked: {
                    rootStore.setActiveCommunity(communityId)
                }

                onInviteFriends: {
                    Global.openInviteFriendsToCommunityPopup(communityData,
                                                             root.profileSectionStore.communitiesProfileModule,
                                                             null)
                }
            }
        }
    }
}

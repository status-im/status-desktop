import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0
import shared.stores 1.0

import SortFilterProxyModel 0.2

import "../panels"
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore
import AppLayouts.Chat.stores 1.0 as ChatStore
import AppLayouts.stores 1.0 as AppLayoutsStores

SettingsContentBase {
    id: root

    property ProfileSectionStore profileSectionStore
    property AppLayoutsStores.RootStore rootStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property CurrenciesStore currencyStore

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
            visible: !root.profileSectionStore.communitiesList.count
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

            Image {
                source: Theme.png("settings/communities")
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
                font.pixelSize: Theme.secondaryAdditionalTextSize
                Layout.topMargin: 35

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            }

            StatusBaseText {
                text: qsTr("Explore and see what communities are trending")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.primaryTextFontSize
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
            spacing: Theme.padding

            Heading {
                text: qsTr("Owner")
                visible: panelOwners.count
            }

            Panel {
                id: panelOwners
                filters: ValueFilter {
                    readonly property int role: Constants.memberRole.owner
                    roleName: "memberRole"
                    value: role
                }
            }

            Heading {
                text: qsTr("TokenMaster")
                visible: panelTokenMasters.count
            }

            Panel {
                id: panelTokenMasters
                filters: ValueFilter {
                    readonly property int role: Constants.memberRole.tokenMaster
                    roleName: "memberRole"
                    value: role
                }
            }

            Heading {
                text: qsTr("Admin")
                visible: panelAdmins.count
            }

            Panel {
                id: panelAdmins
                filters: ValueFilter {
                    readonly property int role: Constants.memberRole.admin
                    roleName: "memberRole"
                    value: role
                }
            }

            Heading {
                text: qsTr("Member")
                visible: panelMembers.count
            }

            Panel {
                id: panelMembers
                filters: FastExpressionFilter {
                    readonly property int ownerRole: Constants.memberRole.owner
                    readonly property int adminRole: Constants.memberRole.admin
                    readonly property int tokenMasterRole: Constants.memberRole.tokenMaster
                    expression: model.joined && model.memberRole !== ownerRole && model.memberRole !== adminRole && model.memberRole !== tokenMasterRole
                    expectedRoles: ["joined", "memberRole"]
                }
            }

            Heading {
                text: qsTr("Pending")
                visible: panelPendingRequests.count
            }

            Panel {
                id: panelPendingRequests
                filters: FastExpressionFilter {
                    expression: model.spectated && !model.joined
                    expectedRoles: ["joined", "spectated"]
                }
            }
        }
    }

    component Heading: StatusBaseText {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        color: Theme.palette.baseColor1
    }

    component Panel: CommunitiesListPanel {
        id: panel

        property var filters

        width: parent.width
        rootStore: root.rootStore

        model: SortFilterProxyModel {
            sourceModel: root.profileSectionStore.communitiesList
            filters: panel.filters
        }

        onCloseCommunityClicked: {
            root.profileSectionStore.communitiesProfileModule.leaveCommunity(communityId)
        }

        onLeaveCommunityClicked: {
            Global.leaveCommunityRequested(community, communityId, outroMessage)
        }

        onSetCommunityMutedClicked: {
            root.profileSectionStore.communitiesProfileModule.setCommunityMuted(communityId, mutedType)
        }

        onSetActiveCommunityClicked: {
            rootStore.setActiveCommunity(communityId)
        }

        onInviteFriends: {
            Global.openInviteFriendsToCommunityPopup(communityData,
                                                     root.profileSectionStore.communitiesProfileModule,
                                                     null)
        }
        onShowCommunityMembershipSetupDialog: {
            Global.communityIntroPopupRequested(communityId, name, introMessage, imageSrc, root.rootStore.isMyCommunityRequestPending(communityId))
        }
        onCancelMembershipRequest: {
            root.rootStore.cancelPendingRequest(communityId)
        }
    }
}

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
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore
import AppLayouts.Chat.stores 1.0 as ChatStore

SettingsContentBase {
    id: root

    property var profileSectionStore
    property var rootStore

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
                filters: ExpressionFilter {
                    readonly property int ownerRole: Constants.memberRole.owner
                    readonly property int adminRole: Constants.memberRole.admin
                    readonly property int tokenMasterRole: Constants.memberRole.tokenMaster
                    expression: model.joined && model.memberRole !== ownerRole && model.memberRole !== adminRole && model.memberRole !== tokenMasterRole
                }
            }

            Heading {
                text: qsTr("Pending")
                visible: panelPendingRequests.count
            }

            Panel {
                id: panelPendingRequests
                filters: ExpressionFilter {
                    expression: model.spectated && !model.joined
                }
            }
        }
    }

    component Heading: StatusBaseText {
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
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
        onShowCommunityIntroDialog: {
            Global.openPopup(communityIntroDialogPopup, {
                communityId: communityId,
                isInvitationPending: root.rootStore.isMyCommunityRequestPending(communityId),
                name: name,
                introMessage: introMessage,
                imageSrc: imageSrc,
                accessType: accessType
            })
        }
        onCancelMembershipRequest: {
            root.rootStore.cancelPendingRequest(communityId)
        }
    }

    readonly property var communityIntroDialogPopup: Component {
        id: communityIntroDialogPopup
        CommunityIntroDialog {
            id: communityIntroDialog

            property string communityId

            readonly property var chatStore: ChatStore.RootStore {
                chatCommunitySectionModule: {
                    root.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(communityIntroDialog.communityId)
                    return root.rootStore.mainModuleInst.getCommunitySectionModule()
                }
            }

            loginType: chatStore.loginType
            walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
            requirementsCheckPending: root.rootStore.requirementsCheckPending
            permissionsModel: {
                root.rootStore.prepareTokenModelForCommunity(communityIntroDialog.communityId)
                return root.rootStore.permissionsModel
            }
            assetsModel: chatStore.assetsModel
            collectiblesModel: chatStore.collectiblesModel

            onPrepareForSigning: {
                chatStore.prepareKeypairsForSigning(communityIntroDialog.communityId, root.rootStore.userProfileInst.name, sharedAddresses, airdropAddress, false)

                communityIntroDialog.keypairSigningModel = chatStore.communitiesModuleInst.keypairsSigningModel
            }

            onSignSharedAddressesForAllNonKeycardKeypairs: {
                chatStore.signSharedAddressesForAllNonKeycardKeypairs()
            }

            onSignSharedAddressesForKeypair: {
                chatStore.signSharedAddressesForKeypair(keyUid)
            }

            onJoinCommunity: {
                chatStore.joinCommunityOrEditSharedAddresses()
            }

            onCancelMembershipRequest: root.rootStore.cancelPendingRequest(communityIntroDialog.communityId)

            onSharedAddressesUpdated: {
                root.rootStore.updatePermissionsModel(communityIntroDialog.communityId, sharedAddresses)
            }

            onClosed: destroy()

            Connections {
                target: chatStore.communitiesModuleInst

                function onSharedAddressesForAllNonKeycardKeypairsSigned() {
                    if (!!communityIntroDialog.replaceItem) {
                        communityIntroDialog.replaceLoader.item.sharedAddressesForAllNonKeycardKeypairsSigned()
                    }
                }
            }
        }
    }
}

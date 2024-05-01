import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

Item {
    id: root

    required property string mainDisplayName
    required property bool readOnly
    required property var communitiesProxyModel
    required property var globalAssetsModel
    required property var globalCollectiblesModel

    property alias cellWidth: communitiesView.cellWidth
    property alias cellHeight: communitiesView.cellHeight

    signal copyToClipboard(string text)
    signal closeRequested()

    StatusBaseText {
        anchors.centerIn: parent
        visible: (communitiesView.count === 0)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.directColor1
        text: qsTr("%1 has not shared any communities").arg(root.mainDisplayName)
    }
    StatusGridView {
        id: communitiesView

        anchors.fill: parent
        topMargin: Style.current.bigPadding
        bottomMargin: Style.current.bigPadding
        leftMargin: Style.current.bigPadding

        visible: count
        model: root.communitiesProxyModel
        ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: width / 2 }
        delegate: StatusCommunityCard {
            id: profileDialogCommunityCard
            readonly property var permissionsList: model.permissionsModel
            readonly property bool requirementsMet: !!model.allTokenRequirementsMet ? model.allTokenRequirementsMet : false
            cardSize: StatusCommunityCard.Size.Small
            implicitWidth: GridView.view.cellWidth - Style.current.padding
            implicitHeight: GridView.view.cellHeight - Style.current.padding
            titleFontSize: 15
            communityId: model.id ?? ""
            loaded: !!model.id && !model.isShowcaseLoading
            asset.source: model.image ?? ""
            asset.isImage: !!model.image
            asset.width: 32
            asset.height: 32
            name: model.name ?? ""
            memberCountVisible: false
            layer.enabled: hovered
            border.width: hovered ? 0 : 1
            border.color: Theme.palette.baseColor2
            banner: model.bannerImageData ?? ""
            descriptionFontSize: 12
            descriptionFontColor: Theme.palette.baseColor1
            description: {
                switch (model.memberRole)  {
                case (Constants.memberRole.owner):
                    return qsTr("Owner");
                case (Constants.memberRole.admin) :
                    return qsTr("Admin");
                case (Constants.memberRole.tokenMaster):
                    return qsTr("Token Master");
                default:
                    return qsTr("Member");
                }
            }
            communityColor: model.color ?? ""
            // Community restrictions
            bottomRowComponent: (model.joined && !root.readOnly) ?
                                    communityMembershipComponent :
                                    !!profileDialogCommunityCard.permissionsList && profileDialogCommunityCard.permissionsList.count > 0 ?
                                        permissionsRowComponent : null

            Component {
                id: communityMembershipComponent
                Item {
                    width: 125
                    height: 24
                    Rectangle {
                        anchors.fill: parent
                        radius: 20
                        color: Theme.palette.successColor1
                        opacity: .1
                        border.color: Theme.palette.successColor1
                    }
                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        StatusIcon {
                            width: 16
                            height: 16
                            color: Theme.palette.successColor1
                            icon: "tiny/checkmark"
                        }
                        StatusBaseText {
                            font.pixelSize: Theme.tertiaryTextFontSize
                            color: Theme.palette.successColor1
                            text: qsTr("You’re there too")
                        }
                    }
                }
            }

            Component {
                id: permissionsRowComponent
                PermissionsRow {
                    hoverEnabled: false
                    assetsModel: root.globalAssetsModel
                    collectiblesModel: root.globalCollectiblesModel
                    model: profileDialogCommunityCard.permissionsList
                    requirementsMet: profileDialogCommunityCard.requirementsMet
                    backgroundBorderColor: Theme.palette.baseColor2
                    backgroundRadius: 20
                }
            }

            onClicked: {
                if (root.readOnly)
                    return
                Global.switchToCommunity(model.id)
                root.closeRequested()
            }
            onRightClicked: {
                if (root.readOnly)
                    return
                Global.openMenu(delegatesActionsMenu, this, { communityId: model.id, url: Utils.getCommunityShareLink(model.id) })
            }
        }
    }

    Component {
        id: delegatesActionsMenu
        StatusMenu {
            id: contextMenu

            property string url
            property string communityId

            StatusAction {
                text: qsTr("Visit community")
                icon.name: "arrow-right"
                onTriggered: {
                    Global.switchToCommunity(contextMenu.communityId);
                    root.closeRequested();
                }
            }

            StatusAction {
                text: qsTr("Invite People")
                icon.name: "share-ios"
                onTriggered: {
                    Global.openInviteFriendsToCommunityByIdPopup(contextMenu.communityId, null);
                }
            }

            StatusSuccessAction {
                id: copyAddressAction
                successText: qsTr("Copied")
                text: qsTr("Copy link to community")
                icon.name: "copy"
                onTriggered: {
                    root.copyToClipboard(contextMenu.url)
                }
            }
        }
    }
}

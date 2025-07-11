import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups

import shared.controls
import shared.controls.delegates

import utils

Item {
    id: root

    required property string mainDisplayName
    required property var assetsModel
    required property bool sendToAccountEnabled

    property alias cellWidth: assetsView.cellWidth
    property alias cellHeight: assetsView.cellHeight

    signal closeRequested()
    signal visitCommunity(var model)

    StatusBaseText {
        anchors.centerIn: parent
        visible: (assetsView.count === 0)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.directColor1
        text: qsTr("%1 has not shared any assets").arg(root.mainDisplayName)
    }
    StatusGridView {
        id: assetsView

        anchors.fill: parent
        topMargin: Theme.bigPadding
        bottomMargin: Theme.bigPadding
        leftMargin: Theme.bigPadding
        
        visible: count

        model: root.assetsModel
        ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: width / 2 }
        delegate: InfoCard {
            id: assetsInfoDelegate
            width: GridView.view.cellWidth - Theme.padding
            height: GridView.view.cellHeight - Theme.padding
            title: model.name
            //TODO show balance & symbol
            subTitle: model.decimals + " " + model.symbol
            asset.name: Constants.tokenIcon(model.symbol)
            asset.isImage: true

            ExpandableTag {
                id: communityTag
                visible: !!model.communityImage
                tagName: model.communityName
                tagImage: model.communityImage
                onTagClicked: {
                    Global.switchToCommunity(model.communityId);
                    root.closeRequested();
                }
            }

            rightSideButtons: RowLayout {
                StatusFlatRoundButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    visible: (assetsInfoDelegate.hovered && !communityTag.hovered && model.communityId === "")
                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "external"
                    icon.width: 16
                    icon.height: 16
                    radius: width/2
                    icon.color: assetsInfoDelegate.hovered && !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
                    enabled: root.sendToAccountEnabled
                    onClicked: {
                        //TODO check this open on CoinGecko
                        Global.openLink(model.url);
                    }
                }
            }
            onCommunityTagClicked: {
                Global.switchToCommunity(model.communityId);
                root.closeRequested();
            }
            onClicked: {
                if ((mouse.button === Qt.LeftButton) && (model.communityId !== "")) {
                    root.visitCommunity(model)
                } else if (mouse.button === Qt.RightButton) {
                    Global.openMenu(delegatesActionsMenu, this, { accountAddress: model.address, communityId: model.communityId });
                }
            }
        }
    }

    Component {
        id: delegatesActionsMenu
        StatusMenu {
            id: contextMenu

            property string communityId
            property string accountAddress: ""

            StatusAction {
                text: qsTr("Visit community")
                enabled: !!contextMenu.communityId
                icon.name: "communities"
                onTriggered: {
                    Global.switchToCommunity(contextMenu.communityId);
                    root.closeRequested();
                }
            }

            StatusAction {
                text: qsTr("View on CoinGecko")
                enabled: false //contextMenu.communityId === ""
                icon.name: "link"
                onTriggered: {
                    //TODO: Get coingecko link for token
                    // let link = "";
                    // Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
                }
            }
        }
    }
}

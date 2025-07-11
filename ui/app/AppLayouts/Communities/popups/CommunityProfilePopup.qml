import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Controls
import StatusQ.Popups


import utils

import AppLayouts.Communities.panels

StatusModal {
    id: root

    property var community
    property var communitySectionModule

    onClosed: {
        while (contentItem.depth > 1) {
            contentItem.pop()
        }
    }

    headerSettings.title: contentItem.currentItem.headerTitle
    headerSettings.subTitle: contentItem.currentItem.headerSubtitle || ""
    headerSettings.asset.name: contentItem.currentItem.headerImageSource || ""
    headerSettings.asset.isImage: !!contentItem.currentItem.headerImageSource
    headerSettings.asset.isLetterIdenticon: contentItem.currentItem.headerTitle === root.community.name && !contentItem.currentItem.headerImageSource
    headerSettings.asset.bgColor: root.community.color

    contentItem: StackView {
        id: stack
        initialItem: profileOverview
        width: root.width
        implicitHeight: currentItem.implicitHeight || currentItem.height

        pushEnter: Transition { enabled: false }
        pushExit: Transition { enabled: false }
        popEnter: Transition { enabled: false }
        popExit: Transition { enabled: false }

        Component {
            id: profileOverview
            ProfilePopupOverviewPanel {
                width: stack.width

                headerTitle: root.community.name
                headerSubtitle: {
                    switch(root.community.access) {
                        case Constants.communityChatPublicAccess: return qsTr("Public community");
                        case Constants.communityChatInvitationOnlyAccess: return qsTr("Invitation only community");
                        case Constants.communityChatOnRequestAccess: return qsTr("On request community");
                        default: return qsTr("Unknown community");
                    }
                }
                headerImageSource: root.community.image
                community: root.community

                onLeaveButtonClicked: {
                    root.close();
                    root.community.spectated ? communitySectionModule.leaveCommunity()
                                             : Global.leaveCommunityRequested(root.community.name, root.community.id, root.community.outroMessage)
                }
                onCopyToClipboard: ClipboardUtils.setText(link)
            }
        }
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            visible: contentItem.depth > 1
            height: !visible ? 0 : implicitHeight
            onClicked: {
                contentItem.pop()
            }

            Layout.minimumWidth: implicitWidth
        }
    ]
}

import QtQuick 2.12
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


import utils 1.0

import AppLayouts.Communities.panels 1.0

StatusModal {
    id: root

    property var store
    property var community
    property var contactsStore
    property bool hasAddedContacts
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
                onCopyToClipboard: {
                    Utils.copyToClipboard(link);
                }
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
        }
    ]
}

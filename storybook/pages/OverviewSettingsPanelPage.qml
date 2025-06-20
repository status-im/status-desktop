import QtQuick 2.14
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import mainui 1.0
import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Communities.panels 1.0

import shared.stores 1.0 as SharedStores

import Models 1.0

SplitView {
    id: root
    SplitView.fillWidth: true

    Popups {
        popupParent: root
        sharedRootStore: SharedStores.RootStore {}
        rootStore: AppLayoutStores.RootStore {}
        communityTokensStore: SharedStores.CommunityTokensStore {}
        networksStore: SharedStores.NetworksStore {}
    }

    OverviewSettingsPanel {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        name: communityEditor.name
        description: communityEditor.description
        logoImageData: communityEditor.image
        color: communityEditor.color
        bannerImageData: communityEditor.banner

        isOwner: communityEditor.amISectionAdmin
        isAdmin: ctrlIsAdmin.checked
        isTokenMaster: ctrlIsTM.checked

        editable: communityEditor.isCommunityEditable
        communitySettingsDisabled: !editable

        shardingEnabled: communityEditor.shardingEnabled
        shardIndex: communityEditor.shardIndex

        isPendingOwnershipRequest: pendingOwnershipSwitch.checked
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth

            CommunityInfoEditor {
                id: communityEditor

                Switch {
                    id: pendingOwnershipSwitch
                    text: "Pending transfer ownership request?"
                }

                Switch {
                    id: ctrlIsAdmin
                    text: "Is admin?"
                }

                Switch {
                    id: ctrlIsTM
                    text: "Is token master?"
                }
            }
        }
    }
}

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=31229-627216&mode=design&t=KoQOW7vmoNc7f41m-0

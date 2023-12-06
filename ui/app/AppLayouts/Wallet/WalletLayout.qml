import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Layout 0.1

import utils 1.0
import shared.controls 1.0
import shared.popups.keypairimport 1.0

import "popups"
import "panels"
import "views"
import "stores"
import "controls"

Item {
    id: root

    property bool hideSignPhraseModal: false
    property bool showAllAccounts: true
    property var store
    property var contactsStore
    property var emojiPopup: null
    property var sendModalPopup
    property var networkConnectionStore

    onVisibleChanged: resetView()

    Connections {
        target: walletSection

        function onFilterChanged(address, allAddresses) {
            root.showAllAccounts = allAddresses
        }

        function onDisplayKeypairImportPopup() {
            keypairImport.active = true
        }

        function onDestroyKeypairImportPopup() {
            keypairImport.active = false
        }
    }
    
    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !RootStore.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    function resetView() {
        if (!!rightPanelStackView.currentItem.resetView)
            rightPanelStackView.currentItem.resetView()
    }

    SignPhraseModal {
        id: signPhrasePopup
        onRemindLaterClicked: hideSignPhraseModal = true
        onAcceptClicked: { RootStore.setHideSignPhraseModal(true); }
    }

    SeedPhraseBackupWarning {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    Component {
        id: cmpSavedAddresses
        SavedAddressesView {
            anchors.top: parent ? parent.top: undefined
            anchors.left: parent ? parent.left: undefined
            anchors.right: parent ? parent.right: undefined
            contactsStore: root.contactsStore
            sendModal: root.sendModalPopup
        }
    }

    Component {
        id: walletContainer
        RightTabView {
            store: root.store
            contactsStore: root.contactsStore
            sendModal: root.sendModalPopup
            networkConnectionStore: root.networkConnectionStore
            showAllAccounts: leftTab.showAllAccounts
            onLaunchShareAddressModal: Global.openPopup(receiveModalComponent);
        }
    }

    StatusSectionLayout {
        anchors.top: seedPhraseWarning.bottom
        height: root.height - seedPhraseWarning.height
        width: root.width
        backButtonName: RootStore.backButtonName
        notificationCount: activityCenterStore.unreadNotificationsCount
        hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

        onNotificationButtonClicked: Global.openActivityCenterPopup()
        onBackButtonClicked: {
            rightPanelStackView.currentItem.resetStack();
        }

        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            changeSelectedAccount: function(address) {
                root.resetView()
                RootStore.setFilterAddress(address)
            }
            selectAllAccounts: function() {
                root.resetView()
                RootStore.setFillterAllAddresses()
            }
            onCurrentAddressChanged: root.resetView()
            onShowSavedAddressesChanged: {
                if(showSavedAddresses)
                    rightPanelStackView.replace(cmpSavedAddresses)
                else
                    rightPanelStackView.replace(walletContainer)
                RootStore.backButtonName = ""
            }
            emojiPopup: root.emojiPopup
            networkConnectionStore: root.networkConnectionStore
        }

        centerPanel: StackView {
            id: rightPanelStackView
            anchors.fill: parent
            anchors.leftMargin: 64
            anchors.rightMargin: 64
            initialItem: walletContainer
            replaceEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
            }
            replaceExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 400; easing.type: Easing.OutCubic }
            }
        }
        headerBackground: AccountHeaderGradient {
            width: parent.width
            overview: RootStore.overview
        }

        footer: WalletFooter {
            id: footer

            readonly property bool isHoldingSelected: !!walletStore.currentViewedCollectible && walletStore.currentViewedHoldingID !== ""
            readonly property bool isCommunityCollectible: !!walletStore.currentViewedCollectible ? walletStore.currentViewedCollectible.communityId !== "" : false
            readonly property bool isOwnerCommunityCollectible: isCommunityCollectible ? (walletStore.currentViewedCollectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false

            visible: !root.showAllAccounts
            width: parent.width
            height: root.showAllAccounts ? implicitHeight : 61
            walletStore: RootStore
            networkConnectionStore: root.networkConnectionStore
            isCommunityOwnershipTransfer: footer.isHoldingSelected && footer.isOwnerCommunityCollectible
            communityName: !!walletStore.currentViewedCollectible ? walletStore.currentViewedCollectible.communityName : ""
            onLaunchShareAddressModal: Global.openPopup(receiveModalComponent)
            onLaunchSendModal: {
                if(isCommunityOwnershipTransfer) {
                    let tokenItem = walletStore.currentViewedCollectible
                    Global.openTransferOwnershipPopup(walletStore.currentViewedCollectible.communityId,
                                                      tokenItem.communityName,
                                                      tokenItem.communityImage,
                                                      {
                                                          "key": walletStore.currentViewedHoldingID,
                                                          "privilegesLevel": tokenItem.communityPrivilegesLevel,
                                                          "chainId": tokenItem.chainId,
                                                          "name": tokenItem.name,
                                                          "artworkSource": tokenItem.artworkSource,
                                                          "accountAddress": leftTab.currentAddress,
                                                          "tokenAddress": tokenItem.contractAddress
                                                      },
                                                      walletStore.accounts,
                                                      root.sendModalPopup)
                } else {
                    // Common send modal popup:
                    root.sendModalPopup.preSelectedSendType = Constants.SendType.Transfer
                    root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingID
                    root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                    root.sendModalPopup.onlyAssets = false
                    root.sendModalPopup.open()
                }
            }
            onLaunchBridgeModal: {
                root.sendModalPopup.preSelectedSendType = Constants.SendType.Bridge
                root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingID
                root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                root.sendModalPopup.onlyAssets = true
                root.sendModalPopup.open()
            }
        }
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            destroyOnClose: true
            anchors.centerIn: parent
        }
    }

    Loader {
        id: keypairImport
        active: false
        asynchronous: true

        sourceComponent: KeypairImportPopup {
            store.keypairImportModule: root.store.walletSectionInst.keypairImportModule
        }

        onLoaded: {
            keypairImport.item.open()
        }
    }
}

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Layout 0.1

import utils 1.0
import shared.controls 1.0

import "popups"
import "panels"
import "views"
import "stores"
import "controls"

Item {
    id: root

    property bool hideSignPhraseModal: false
    property var store
    property var contactsStore
    property var emojiPopup: null
    property var sendModalPopup
    property var networkConnectionStore

    onVisibleChanged: resetView()

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

        Component.onCompleted: {
            // Read in RootStore
//            if(RootStore.firstTimeLogin){
//                RootStore.firstTimeLogin = false
//                RootStore.setInitialRange()
//            }
        }

        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            changeSelectedAccount: function(address) {
                RootStore.setFilterAddress(address)
                root.resetView()
            }
            selectAllAccounts: function() {
                RootStore.setFillterAllAddresses()
                root.resetView()
            }
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
            sendModal: root.sendModalPopup
            width: parent.width
            walletStore: RootStore
            networkConnectionStore: root.networkConnectionStore
            onLaunchShareAddressModal: Global.openPopup(receiveModalComponent)
        }
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            anchors.centerIn: parent
        }
    }

    Connections {
        target: RootStore.walletSectionInst
        function onShowToastAccountAdded(name: string) {
            Global.displayToastMessage(
                qsTr("\"%1\" successfuly added").arg(name),
                "",
                "check-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }
    }
}

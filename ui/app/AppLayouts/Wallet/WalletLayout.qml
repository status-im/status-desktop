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

Item {
    id: walletView

    property bool hideSignPhraseModal: false

    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !RootStore.hideSignPhraseModal){
            signPhrasePopup.open();
        }
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


    StatusAppTwoPanelLayout {
        anchors.top: seedPhraseWarning.bottom
        height: walletView.height - seedPhraseWarning.height
        width: walletView.width

        Component.onCompleted: {
            // Read in RootStore
//            if(RootStore.firstTimeLogin){
//                RootStore.firstTimeLogin = false
//                RootStore.setInitialRange()
//            }
        }

        Timer {
            id: recentHistoryTimer
            interval: Constants.walletFetchRecentHistoryInterval
            running: true
            repeat: true
            onTriggered: RootStore.checkRecentHistory()
        }
        
        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            changeSelectedAccount: function(newIndex) {
                if (newIndex > RootStore.accounts) {
                    return
                }
                selectedAccountIndex = newIndex
                RootStore.switchAccount(newIndex)
                walletContainer.currentTabIndex = 0;
            }
        }

        rightPanel: RightTabView {
            id: walletContainer
            anchors.fill: parent
            changeSelectedAccount: leftTab.changeSelectedAccount
        }
    }
}

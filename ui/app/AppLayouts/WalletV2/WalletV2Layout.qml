import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../shared"
import "../../../shared/controls"

import "stores"
import "controls"
import "views"
import "panels"
import "popups"
import "views/assets"
import "views/collectibles"

import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

Item {
    id: walletView

    property bool hideSignPhraseModal: false
    property RootStore store: RootStore { }

    function showSigningPhrasePopup() {
        //TODO improve this to not use dynamic scoping
        if(!hideSignPhraseModal && !localAccountSensitiveSettings.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
        signingPhraseText: walletView.store.walletModelInst.utilsView.signingPhrase
        onRemindLaterButtonClicked: {
            hideSignPhraseModal = true;
            signPhrasePopup.close();
        }
    }
        
    SeedPhraseBackupWarningPanel {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
        visible: !walletView.store.profileModelInst.mnemonic.isBackedUp
    }

    StatusAppTwoPanelLayout {
        id: layoutWalletTwoPanel
        anchors.top: seedPhraseWarning.bottom
        height: walletView.height - seedPhraseWarning.height
        width: walletView.width

        Component.onCompleted: {
            // Read in RootStore
//            if (walletView.store.onboardingModelInst.firstTimeLogin) {
//                walletView.store.onboardingModelInst.firstTimeLogin = false;
//                walletView.store.walletModelInst.setInitialRange();
//            }
        }
        
        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            store: walletView.store
            onSavedAddressesClicked: {
                if (selected) {
                    stackView.replace(cmpSavedAddresses);
                } else {
                    stackView.replace(walletInfoContent);
                }
            }
        }

        rightPanel: Item {
            property alias view: stackView
            anchors.fill: parent
            RowLayout {
                id: walletInfoContainer
                anchors.top: parent.top
                anchors.topMargin: 31
                anchors.bottom: walletFooter.top
                anchors.bottomMargin: 24
                anchors.left: parent.left
                anchors.leftMargin: 80
                anchors.right: parent.right
                anchors.rightMargin: 80
                StackBaseView {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    initialItem: Item {
                        id: walletInfoContent
                        WalletHeaderPanel {
                            id: walletHeader
                            accountsModel: walletView.store.walletModelV2Inst.accountsView.accounts
                            currentAccount: walletView.store.walletModelV2Inst.accountsView.currentAccount
                            qrCode: walletView.store.profileModelInst.qrCode(walletView.store.selectedAccount.address)
                            allNetworksModel: walletView.store.walletModelV2Inst.networksView.allNetworks
                            enabledNetworksModel: walletView.store.walletModelV2Inst.networksView.enabledNetworks
                            onToggleNetwork: {
                                walletView.store.walletModelV2Inst.networksView.toggleNetwork(chainId)
                            }
                            onCopyText: {
                                walletView.store.copyText(text);
                            }
                        }
                        TabBar {
                            id: walletTabBar
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: walletHeader.bottom
                            anchors.topMargin: Style.current.padding
                            height: childrenRect.height
                            spacing: 24
                            background: null
                            StatusTabButton {
                                id: assetsBtn
                                btnText: qsTr("Assets")
                            }
                            StatusTabButton {
                                id: positionsBtn
                                btnText: qsTr("Positions")
                            }
                            StatusTabButton {
                                id: collectiblesBtn
                                btnText: qsTr("Collectibles")
                            }
                            StatusTabButton {
                                id: activityBtn
                                btnText: qsTr("Activity")
                            }
                        }
                        StackLayout {
                            id: stackLayout
                            anchors.top: walletTabBar.bottom
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.topMargin: Style.current.bigPadding
                            currentIndex: walletTabBar.currentIndex

                            AssetsView {
                                id: assetsTab
                                onAssetClicked: {
                                    stackView.replace(assetDetailView);
                                }
                            }
                            PositionsView {
                                id: positionsTab
                            }
                            CollectiblesView {
                                id: collectiblesTab
                                store: walletView.store
                                onCollectibleClicked: {
                                    stackView.replace(collectibleDetailView);
                                }
                            }
                            ActivityView {
                                id: activityTab
                            }
                        }
                    }
                }
            }

            Component {
                id: assetDetailView
                AssetDetailView {
                    onBackPressed: {
                        stackView.replace(walletInfoContent);
                    }
                }
            }

            Component {
                id: collectibleDetailView
                CollectibleDetailView {
                    store: walletView.store
                    onBackPressed: {
                        stackView.replace(walletInfoContent);
                    }
                }
            }

            Component {
                id: cmpSavedAddresses
                SavedAddressesView {
                    store: walletView.store
                }
            }

            WalletFooterPanel {
                id: walletFooter
                anchors.bottom: parent.bottom
                walletV2Model: walletView.store.walletModelV2Inst
            }
        }
    }
}

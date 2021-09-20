import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "views"
import "views/assets"
import "."
import "./components"

import StatusQ.Controls 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

Item {
    id: walletView

    property bool hideSignPhraseModal: false

    function showSavedAddressesView() {
        layoutWalletTwoPanel.rightPanel.view.replace(cmpSavedAddresses);
    }

    function hideSavedAddressesView() {
        layoutWalletTwoPanel.rightPanel.view.replace(walletInfoContent);
    }

    function openCollectibleDetailView(options) {
        collectiblesDetailPage.active = true
        collectiblesDetailPage.item.show(options)
    }

    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !appSettings.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
    }

    SeedPhraseBackupWarning {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    StatusAppTwoPanelLayout {
        id: layoutWalletTwoPanel
        anchors.top: seedPhraseWarning.bottom
        height: walletView.height - seedPhraseWarning.height
        width: walletView.width

        Component.onCompleted: {
            if(onboardingModel.firstTimeLogin){
                onboardingModel.firstTimeLogin = false
                walletModel.setInitialRange()
            }
        }
        
        leftPanel: LeftTab {
            id: leftTab
            anchors.fill: parent
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
                visible: !collectiblesDetailPage.active
                anchors.rightMargin: 80
                StackBaseView {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    initialItem: Item {
                        id: walletInfoContent
                        WalletHeader {
                            id: walletHeader
                            changeSelectedAccount: leftTab.changeSelectedAccount
                        }
                        TabBar {
                            id: walletTabBar
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: walletHeader.bottom
                            anchors.topMargin: Style.current.padding
                            height: childrenRect.height
                            spacing: 24
                            background: Rectangle {
                                color: Style.current.transparent
                            }
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
                            StatusTabButton {
                                id: settingsBtn
                                btnText: qsTr("Settings")
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
                            }
                            ActivityView {
                                id: activityTab
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

                        SettingsTab {
                            id: settingsTab
                        }
                    }
                }
                Component {
                    id: cmpSavedAddresses
                    SavedAddresses {}
                }
            }

            WalletFooter {
                id: walletFooter
                anchors.bottom: parent.bottom
            }

            Loader {
                id: collectiblesDetailPage
                anchors.bottom: walletFooter.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                active: false
                sourceComponent: CollectibleDetailsPage {
                    anchors.fill: parent
                }
            }
        }
    }
}

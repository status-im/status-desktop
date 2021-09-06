import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "."

import StatusQ.Layout 0.1

Item {
    id: walletView

    property bool hideSignPhraseModal: false

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
            anchors.fill: parent

            WalletHeader {
                id: walletHeader
                changeSelectedAccount: leftTab.changeSelectedAccount
            }

            RowLayout {
                id: walletInfoContainer
                anchors.bottom: walletFooter.top
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: walletHeader.bottom
                anchors.topMargin: 23

                Item {
                    id: walletInfoContent
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    TabBar {
                        id: walletTabBar
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.top: parent.top
                        anchors.topMargin: Style.current.padding
                        height: collectiblesBtn.height
                        background: Rectangle {
                            color: Style.current.transparent
                        }
                        StatusTabButton {
                            id: collectiblesBtn
                            btnText: qsTr("Collectibles")
                        }
                        StatusTabButton {
                            id: settingsBtn
                            anchors.left: collectiblesBtn.right
                            anchors.leftMargin: walletInfoContent.width - collectiblesBtn.width - 100
                            btnText: qsTr("Settings")
                        }
                    }

                    StackLayout {
                        id: stackLayout
                        anchors.top: walletTabBar.bottom
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: Style.current.padding
                        currentIndex: walletTabBar.currentIndex

                        CollectiblesTab {
                            id: collectiblesTab
                        }

                        SettingsTab {
                            id: settingsTab
                        }
                    }
                }
            }

            WalletFooter {
                id: walletFooter
                anchors.bottom: parent.bottom
            }
        }
    }
}

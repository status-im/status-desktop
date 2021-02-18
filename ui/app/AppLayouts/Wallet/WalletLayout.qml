import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "."

ColumnLayout {
    property bool hideSignPhraseModal: false

    SignPhraseModal {
        id: signPhrasePopup
    }
    
    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !appSettings.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }
    
    SeedPhraseBackupWarning { }
    
    SplitView {
        id: walletView
        Layout.fillHeight: true
        Layout.fillWidth: true

        handle: SplitViewHandle {}

        Connections {
            target: appMain
            onSettingsLoaded: {
                // Add recent
                walletView.restoreState(appSettings.walletSplitView)
            }
        }
        Component.onDestruction: appSettings.walletSplitView = this.saveState()

        LeftTab {
            id: leftTab
            SplitView.preferredWidth: Style.current.leftTabPrefferedSize
            SplitView.minimumWidth: Style.current.leftTabMinimumWidth
            SplitView.maximumWidth: Style.current.leftTabMaximumWidth
        }
        
        Item {
            id: walletContainer
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: leftTab.right
            anchors.leftMargin: 0

            WalletHeader {
                id: walletHeader
                changeSelectedAccount: leftTab.changeSelectedAccount
            }

            RowLayout {
                id: walletInfoContainer
                anchors.bottom: parent.bottom
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
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.bigPadding
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.top: parent.top
                        anchors.topMargin: Style.current.padding
                        height: assetBtn.height
                        background: Rectangle {
                            color: Style.current.transparent
                        }

                        StatusTabButton {
                            id: assetBtn
                            tabColor: walletModel.currentAccount.iconColor
                            //% "Assets"
                            btnText: qsTrId("wallet-assets")
                        }
                        StatusTabButton {
                            id: collectiblesBtn
                            tabColor: walletModel.currentAccount.iconColor
                            anchors.left: assetBtn.right
                            anchors.leftMargin: 32
                            //% "Collectibles"
                            btnText: qsTrId("wallet-collectibles")
                        }
                        StatusTabButton {
                            id: historyBtn
                            tabColor: walletModel.currentAccount.iconColor
                            anchors.left: collectiblesBtn.right
                            anchors.leftMargin: 32
                            //% "History"
                            btnText: qsTrId("history")
                            onClicked: historyTab.checkIfHistoryIsBeingFetched()
                        }
                    }

                    StackLayout {
                        id: stackLayout
                        anchors.rightMargin: Style.current.bigPadding
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.top: walletTabBar.bottom
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: Style.current.bigPadding
                        currentIndex: walletTabBar.currentIndex

                        AssetsTab {
                            id: assetsTab
                        }
                        CollectiblesTab {
                            id: collectiblesTab
                        }
                        HistoryTab {
                            id: historyTab
                        }
                    }
                }
            }
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:770;width:1152}
}
##^##*/

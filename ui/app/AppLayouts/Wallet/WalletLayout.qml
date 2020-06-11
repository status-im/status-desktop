import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "."

SplitView {
    id: walletView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    handleDelegate: Rectangle {
        implicitWidth: 1
        implicitHeight: 4
        color: Theme.grey
    }

    LeftTab {
        id: leftTab
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
                    anchors.rightMargin: Theme.bigPadding
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.bigPadding
                    anchors.top: parent.top
                    anchors.topMargin: Theme.padding
                    height: assetBtn.height

                    StatusTabButton {
                        id: assetBtn
                        btnText: "Assets"
                    }
                    StatusTabButton {
                        id: collectiblesBtn
                        anchors.left: assetBtn.right
                        anchors.leftMargin: 32
                        btnText: "Collectibles"
                    }
                    StatusTabButton {
                        id: historyBtn
                        anchors.left: collectiblesBtn.right
                        anchors.leftMargin: 32
                        btnText: "History"
                    }
                }

                StackLayout {
                    id: stackLayout
                    anchors.rightMargin: Theme.bigPadding
                    anchors.leftMargin: Theme.bigPadding
                    anchors.top: walletTabBar.bottom
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.topMargin: Theme.bigPadding
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
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:770;width:1152}
}
##^##*/


import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import "../../../../imports"
import "../../../../shared"
import "./MainViewComponents"

Item {

    property var tabsIndexMap: (new Map([
                                       [rightPanelRoot.rightPanelViewMainTabAssets, 0],
                                       [rightPanelRoot.rightPanelViewMainTabPositions, 1],
                                       [rightPanelRoot.rightPanelViewMainTabCollectibles, 2],
                                       [rightPanelRoot.rightPanelViewMainTabActivity, 3],
                                       [rightPanelRoot.rightPanelViewMainTabSettings, 4]
                                   ]))

    function switchTo(subView = "")
    {
        let index = tabsIndexMap.get(subView)
        if(index !== undefined)
            walletTabBar.currentIndex = index
        else
            walletTabBar.currentIndex = 0 // default
    }

    Header {
        id: walletHeader
        changeSelectedAccount: leftPanel.changeSelectedAccount
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
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: parent.top
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

                onCurrentIndexChanged: {
                    if(currentIndex === activityTab.order)
                    {
                        walletV2Model.activityTabController.fetchInitialActivities()
                    }
                }

                AssetsTab {
                    id: assetsTab
                    readonly property int order: 0
                }

                PositionsTab {
                    id: positionsTab
                    readonly property int order: 1
                }

                CollectiblesTab {
                    id: collectiblesTab
                    readonly property int order: 2
                }

                ActivityTab {
                    id: activityTab
                    readonly property int order: 3
                }

                SettingsTab {
                    id: settingsTab
                    readonly property int order: 4
                }
            }
        }
    }

    Footer {
        id: walletFooter
        anchors.bottom: parent.bottom
    }
}

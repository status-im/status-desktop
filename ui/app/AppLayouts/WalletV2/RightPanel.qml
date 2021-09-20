import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import "./components"
import "./RightPanels"

StackLayout {
    id: rightPanelRoot

    readonly property string rightPanelViewMain: "MainView"
    readonly property string rightPanelViewMainTabAssets: "Assets"
    readonly property string rightPanelViewMainTabPositions: "Positions"
    readonly property string rightPanelViewMainTabCollectibles: "Collectibles"
    readonly property string rightPanelViewMainTabActivity: "Activity"
    readonly property string rightPanelViewMainTabSettings: "Settings"
    readonly property string rightPanelViewActivityItem: "ActivityItemView"
    readonly property string rightPanelViewCollectiblesItemView: "CollectiblesItemView"

    function switchTo(mainView, subView = "")
    {
        if(mainView === rightPanelViewActivityItem)
            rightPanelRoot.currentIndex = 1
        else if(mainView === rightPanelViewCollectiblesItemView)
            rightPanelRoot.currentIndex = 2
        else if(mainView === rightPanelViewMainTabActivity)
            rightPanelRoot.currentIndex = 3
        else
        {
            rightPanelRoot.currentIndex = 0 // default
            rightPanelMainView.switchTo(subView)
        }
    }

    MainView {
        id: rightPanelMainView
    }

    ActivityItemView {
        id: rightPanelActivityItem
    }

    CollectibleItemView {
        id: collectiblesItemView
    }

    AssetItemView {
        id: activityItemView
    }
}

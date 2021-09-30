import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls 1.0 as QQC1

import "../controls/styles"

QQC1.TabView {
    id: tabs

    property int tabHeight: 40
    property var tabComponent

    function createEmptyTab(profile, createAsStartPage) {
        var tab = addTab("", tabComponent);
        // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
        tab.active = true;
        createAsStartPage = createAsStartPage || tabs.count === 1
        tab.title = Qt.binding(function() {
            if (tab.item.title) {
                return tab.item.title
            }

            if (createAsStartPage) {
                //% "Start Page"
                return qsTrId("start-page")
            }
            //% "New Tab"
            return qsTrId("new-tab")
        })

        if (createAsStartPage) {
            tab.item.url = "https://dap.ps"
        }

        tab.item.profile = profile;
        if (appSettings.browserHomepage !== "") {
            tab.item.url = appSettings.browserHomepage
        }
        return tab;
    }

    function createDownloadTab(profile) {
        var tab = addTab("", tabComponent);
        tab.active = true;
        //% "Downloads Page"
        tab.title = qsTrId("downloads-page")
        tab.item.profile = profile
        tab.item.url = "status://downloads";
    }

    function indexOfView(view) {
        for (let i = 0; i < tabs.count; ++i)
            if (tabs.getTab(i).item === view)
                return i
        return -1
    }

    function removeView(index) {
        if (tabs.count === 1) {
            tabs.createEmptyTab(currentWebView.profile, true)
        }
        tabs.removeTab(index)
    }

    function openNewTabClicked() {
        addNewTab()
    }

    function closeButtonClicked(index) {
        removeView(index)
    }

    Component.onCompleted: {
        defaultProfile.downloadRequested.connect(onDownloadRequested);
        otrProfile.downloadRequested.connect(onDownloadRequested);
        var tab = createEmptyTab(defaultProfile);
        // For Devs: Uncomment the next lien if you want to use the simpeldapp on first load
        // tab.item.url = Web3ProviderStore.determineRealURL("https://simpledapp.eth");
    }

    style: BrowserTabStyle {}
}

import QtQuick 2.13
import QtQuick.Controls 1.0 as QQC1

import utils 1.0

import "../controls/styles"

QQC1.TabView {
    id: tabs

    property var currentWebEngineProfile
    property var tabComponent
    property var determineRealURL: function(url) {}
    readonly property int tabHeight: 40

    signal openNewTabTriggered()

    function createEmptyTab(profile, createAsStartPage) {
        var tab = addTab("", tabComponent);
        // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
        tab.active = true;
        createAsStartPage = createAsStartPage || tabs.count === 1
        tab.title = Qt.binding(function() {
            var tabTitle = ""
            if (tab.item.title) {
                tabTitle = tab.item.title
            }
            else if (createAsStartPage) {
                tabTitle = qsTr("Start Page")
            }
            else {
                tabTitle = qsTr("New Tab")
            }

            return Utils.escapeHtml(tabTitle);
        })

        if (createAsStartPage) {
            tab.item.url = "https://dap.ps"
        }

        tab.item.profile = profile;
        if (localAccountSensitiveSettings.browserHomepage !== "") {
            tab.item.url = determineRealURL(localAccountSensitiveSettings.browserHomepage)
        }
        return tab;
    }

    function createDownloadTab(profile) {
        var tab = addTab("", tabComponent);
        tab.active = true;
        tab.title = qsTr("Downloads Page")
        tab.item.profile = profile
        tab.item.url = "status://downloads";
    }

    function indexOfView(view) {
        for (let i = 0; i < tabs.count; ++i)
            if (tabs.getTab(i).item === view)
                return i
        return -1
    }

    function openNewTabClicked() {
         openNewTabTriggered()
     }

    function removeView(index) {
        if (tabs.count === 1) {
            tabs.createEmptyTab(currentWebEngineProfile, true)
        }
        tabs.removeTab(index)
    }

    function closeButtonClicked(index) {
        removeView(index)
    }

    style: BrowserTabStyle {}
}

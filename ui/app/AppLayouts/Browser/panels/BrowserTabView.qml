import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Core.Utils as SQUtils

import utils

// FIXME
FocusScope {
    id: root

    property alias currentIndex: tabBar.currentIndex
    readonly property alias count: tabBar.count

    function getTab(index) {
        return tabLayout.children[index]
    }

    function getCurrentTab() {
        return getTab(currentIndex)
    }

    property var currentWebEngineProfile
    property var tabComponent
    property var determineRealURL: function(url) {}
    readonly property int tabHeight: 48

    signal openNewTabTriggered()

    TabBar {
        id: tabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Theme.halfPadding
        height: root.tabHeight
        // TODO catch clicks on empty space and call openNewTabClicked()
    }

    StackLayout {
        id: tabLayout
        currentIndex: tabBar.currentIndex

        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    function createEmptyTab(profile, createAsStartPage = false, focusOnNewTab = true, url = undefined) {
        createAsStartPage = createAsStartPage || tabLayout.count === 1

        var webview = tabComponent.createObject(tabLayout, {profile})

        const tabTitle = Qt.binding(function() {
            var tabTitle = ""
            if (webview.title) {
                tabTitle = webview.title
            } else if (createAsStartPage) {
                tabTitle = qsTr("Start Page")
            } else {
                tabTitle = qsTr("New Tab")
            }

            return SQUtils.StringUtils.escapeHtml(tabTitle);
        })

        var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle})
        tabBar.addItem(newTabButton);

        if (createAsStartPage) {
            webview.url = "https://dap.ps"
        } else if (url !== undefined) {
            webview.url = url;
        } else if (localAccountSensitiveSettings.browserHomepage !== "") {
            webview.url = determineRealURL(localAccountSensitiveSettings.browserHomepage)
        }

        if (focusOnNewTab) {
            tabBar.setCurrentIndex(tabBar.count - 1);
        }

        return webview;
    }

    function removeView(index) {
        if (tabBar.count > 1) {
            tabBar.removeItem(tabBar.itemAt(index));
            tabLayout.children[index].destroy();
        } else {
            createEmptyTab(currentWebEngineProfile, true)
        }
    }

    Component {
        id: tabButtonComponent

        StatusTabButton {
            id: tabButton
            property string tabTitle

            horizontalPadding: Theme.halfPadding

            background: Rectangle {
                color: tabButton.checked ? "transparent" : Theme.palette.baseColor2
            }

            contentItem: RowLayout {
                StatusBaseText {
                    Layout.fillWidth: true
                    elide: Qt.ElideRight
                    font: tabButton.font
                    color: !enabled ? Theme.palette.baseColor1 : tabButton.checked || tabButton.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    Behavior on color {ColorAnimation {duration: Theme.AnimationDuration.Fast}}
                    text: tabButton.tabTitle
                }
                StatusFlatButton {
                    Layout.alignment: Qt.AlignRight
                    size: StatusBaseButton.Size.XSmall
                    icon.name: "close"
                    icon.color: hovered ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                    onClicked: root.removeView(tabButton.TabBar.index)
                }
            }
        }
    }

    function createDownloadTab(profile) {
        var webview = tabComponent.createObject(tabLayout, {profile, url: "status://downloads"})
        var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle: qsTr("Downloads Page")})
        tabBar.addItem(newTabButton);
        return webview;
    }

    function openNewTabClicked() {
        openNewTabTriggered()
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Utils as SQUtils

import utils

FocusScope {
    id: root

    property alias currentIndex: tabBar.currentIndex
    readonly property alias count: tabBar.count
    required property bool thirdpartyServicesEnabled

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
        background: Rectangle {
            color: Theme.palette.baseColor2
        }
        contentItem: ListView {
            model: tabBar.contentModel
            currentIndex: tabBar.currentIndex
            clip: true
            spacing: tabBar.spacing
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.AutoFlickIfNeeded
            snapMode: ListView.SnapToItem

            TapHandler {
                exclusiveSignals: TapHandler.DoubleTap
                onDoubleTapped: {
                    root.openNewTabTriggered()
                }
            }
        }
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

        if (createAsStartPage && root.thirdpartyServicesEnabled) {
            // webview.url = "https://dap.ps" // TODO uncomment with https://github.com/status-im/status-desktop/issues/18545
            webview.url = Constants.externalStatusLinkWithHttps
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

    function createDownloadTab(profile) {
        var webview = tabComponent.createObject(tabLayout, {profile, isDownloadView: true})
        var newTabButton = tabButtonComponent.createObject(tabBar, {tabTitle: qsTr("Downloads Page")})
        tabBar.addItem(newTabButton);
        return webview;
    }

    function removeView(index) {
        if (tabBar.count > 1) {
            tabBar.removeItem(tabBar.itemAt(index))
            var tab = getTab(index)
            tab.stop()
            tab.parent = null // reparent to null first to prevent a crash
            tab.destroy()
        } else {
            createEmptyTab(currentWebEngineProfile, true)
        }
    }

    Component {
        id: tabButtonComponent

        StatusTabButton {
            id: tabButton
            property string tabTitle

            width: implicitWidth
            horizontalPadding: Theme.halfPadding
            verticalPadding: Theme.padding

            background: Rectangle {
                color: tabButton.checked ? Theme.palette.background : Theme.palette.baseColor2
            }

            contentItem: RowLayout {
                StatusIcon {
                    Layout.preferredWidth: 13
                    Layout.preferredHeight: 13
                    opacity: tabButton.checked || tabButton.hovered ? 1 : Theme.disabledOpacity
                    Behavior on opacity {OpacityAnimator {duration: Theme.AnimationDuration.Fast}}
                    sourceSize: Qt.size(width, height)
                    icon: root.getTab(tabButton.TabBar.index) ? root.getTab(tabButton.TabBar.index).icon.toString().replace("image://favicon/", "")
                                                              : "globe"
                    visible: !loadingIndicator.visible
                }
                StatusLoadingIndicator {
                    id: loadingIndicator
                    Layout.preferredWidth: 13
                    Layout.preferredHeight: 13
                    opacity: tabButton.checked || tabButton.hovered ? 1 : Theme.disabledOpacity
                    visible: root.getTab(tabButton.TabBar.index) ? root.getTab(tabButton.TabBar.index).loading : false
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    elide: Qt.ElideRight
                    font: tabButton.font
                    color: !enabled ? Theme.palette.baseColor1 : tabButton.checked || tabButton.hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    Behavior on color {ColorAnimation {duration: Theme.AnimationDuration.Fast}}
                    text: tabButton.tabTitle
                }
                StatusIcon {
                    Layout.preferredWidth: 13
                    Layout.preferredHeight: 13
                    opacity: tabButton.checked || tabButton.hovered ? 1 : Theme.disabledOpacity
                    Behavior on opacity {OpacityAnimator {duration: Theme.AnimationDuration.Fast}}
                    icon: "hide"
                    visible: root.getTab(tabButton.TabBar.index) ? root.getTab(tabButton.TabBar.index).profile.offTheRecord : false
                }
                StatusFlatButton {
                    Layout.alignment: Qt.AlignRight
                    size: StatusBaseButton.Size.XSmall
                    icon.name: "close"
                    icon.color: hovered ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                    onClicked: root.removeView(tabButton.TabBar.index)
                }
            }

            // MMB to close tab handler
            TapHandler {
                acceptedButtons: Qt.MiddleButton
                onTapped: root.removeView(tabButton.TabBar.index)
            }
        }
    }
}

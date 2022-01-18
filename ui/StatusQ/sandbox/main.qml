import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.13

import Sandbox 0.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Platform 0.1

StatusWindow {
    id: rootWindow
    width: Qt.platform.os == "ios" || Qt.platform.os == "android" ? Screen.width
                                                                  :  1224
    height: Qt.platform.os == "ios" || Qt.platform.os == "android" ? Screen.height
                                                                   :840
    visible: true
    title: qsTr("StatusQ Documentation App")

    property ThemePalette lightTheme: StatusLightTheme {}
    property ThemePalette darkTheme: StatusDarkTheme {}

    readonly property real maxFactor: 2.0
    readonly property real minFactor: 0.5

    property real factor: 1.0

    Component.onCompleted: {
        Theme.palette = lightTheme
        apiDocsButton.checked = true

        rootWindow.updatePosition();
    }

    StatusAppLayout {
        id: appLayout
        anchors.fill: parent

        appNavBar: StatusAppNavBar {
            height: rootWindow.height

            navBarChatButton: StatusNavBarTabButton {
                icon.name: "refresh"
                tooltip.text: "Reload App"
                onClicked: app.restartQml()
            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    id: apiDocsButton
                    icon.name: "edit"
                    tooltip.text: "API Documentation"
                    onClicked: {
                        stackView.clear()
                        stackView.push(libraryDocumentationCmp)
                        checked = !checked
                        demoAppButton.checked = false
                    }
                },
                StatusNavBarTabButton {
                    id: demoAppButton
                    icon.name: "status"
                    tooltip.text: "Demo Application"
                    checked: stackView.currentItem == demoAppCmp
                    onClicked: {
                        stackView.clear()
                        stackView.push(demoAppCmp)
                        checked = !checked
                        apiDocsButton.checked = false
                    }
                }
            ]
        }

        appView: StackView {
            id: stackView
            anchors.fill: parent
            initialItem: libraryDocumentationCmp
        }

        ThemeSwitch {
            anchors.top: parent.top
            anchors.topMargin: 32
            anchors.right: parent.right
            anchors.rightMargin: 32
            onCheckedChanged: {
                if (Theme.palette === rootWindow.lightTheme) {
                    Theme.palette = rootWindow.darkTheme
                } else {
                    Theme.palette = rootWindow.lightTheme
                }
            }
        }
    }

    Component {
        id: libraryDocumentationCmp

        StatusAppTwoPanelLayout {
            id: mainPageView

            function page(name) {
                viewLoader.source = Qt.resolvedUrl("./pages/" + name + "Page.qml");
            }
            function control(name) {
                viewLoader.source = Qt.resolvedUrl("./controls/" + name + ".qml");
            }

            leftPanel: Item {
                anchors.fill: parent
                ScrollView {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    contentHeight: navigation.height + 56
                    contentWidth: navigation.width
                    clip: true
                    Column {
                        id: navigation
                        anchors.top: parent.top
                        anchors.topMargin: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        StatusListSectionHeadline { text: "StatusQ.Core" }
                        StatusNavigationListItem { 
                            title: "Icons"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.control(title);
                        }

                        StatusListSectionHeadline { text: "StatusQ.Layout" }
                        StatusNavigationListItem { 
                            title: "Layouts"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.control(title.substring(0, title.length - 1));
                        }

                        StatusListSectionHeadline { text: "StatusQ.Controls" }
                        StatusNavigationListItem { 
                            title: "Buttons"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.control(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusSwitchTab"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page("StatusTabSwitch");
                        }
                        StatusNavigationListItem { 
                            title: "StatusChatCommandButton"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "Controls"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.control(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusTabBarIconButton"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusInput"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusSelect"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusAccountSelector"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusAssetSelector"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusColorSelector"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusWalletColorButton"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "StatusWalletColorSelect"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusListSectionHeadline { text: "StatusQ.Components" }
                        StatusNavigationListItem { 
                            title: "StatusAddress"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "List Items"
                            selected: viewLoader.source.toString().includes(title.replace(/\s+/g, ''))
                            onClicked: mainPageView.control(title.replace(/\s+/g, ''));
                        }
                        StatusNavigationListItem { 
                            title: "StatusChatInfoToolBar"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem { 
                            title: "Others"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.control(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusExpandableItem"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page("StatusExpandableSettingsItem");
                        }
                        StatusListSectionHeadline { text: "StatusQ.Popup" }
                        StatusNavigationListItem { 
                            title: "StatusPopupMenu"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }

                        StatusNavigationListItem {
                            title: "StatusModal"
                            selected: viewLoader.source.toString().includes("Popups")
                            onClicked: mainPageView.control("Popups");
                        }
                        StatusListSectionHeadline { text: "StatusQ.Platform" }
                        StatusNavigationListItem {
                            title: "StatusMacNotification"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                    }
                }
            }

            rightPanel: Item {
                id: rightPanel
                anchors.fill: parent
                ScrollView {
                    anchors.fill: parent
                    contentHeight: (pageWrapper.height + pageWrapper.anchors.topMargin) * rootWindow.factor
                    contentWidth: (pageWrapper.width * rootWindow.factor)
                    clip: true

                    Item {
                        id: pageWrapper
                        width: rightPanel.width
                        anchors.top: parent.top
                        anchors.topMargin: 64
                        height: Math.max(rootWindow.height, viewLoader.height + 128)
                        scale: rootWindow.factor
                        Loader {
                            id: viewLoader
                            anchors.centerIn: parent
                            source: control("Icons")
                        }
                    }
                }
            }
        }
    }

    Action {
        shortcut: "CTRL+="
        onTriggered: {
            if (rootWindow.factor < 2.0)
                rootWindow.factor += 0.2
        }
    }

    Action {
        shortcut: "CTRL+-"
        onTriggered: {
            if (rootWindow.factor > 0.5)
                rootWindow.factor -= 0.2
        }
    }

    Action {
        shortcut: "CTRL+0"
        onTriggered: {
            rootWindow.factor = 1.0
        }
    }

    Component {
        id: demoAppCmp

        Rectangle {
            anchors.fill: parent
            color: Theme.palette.baseColor3

            Row {
                id: platformSwitch
                anchors.left: demoApp.left
                anchors.bottom: demoApp.top
                anchors.bottomMargin: 20
                spacing: 2

                Text {
                    text: "OSX"
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                }

                StatusSwitch {
                    onCheckedChanged: {
                        if (checked) {
                            demoApp.titleStyle = "windows"
                        } else {
                            demoApp.titleStyle = "osx"
                        }
                    }
                }

                Text {
                    text: "Win"
                    font.pixelSize: 15
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            DemoApp {
                id: demoApp
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            DropShadow {
                anchors.fill: demoApp
                source: demoApp
                horizontalOffset: 0
                verticalOffset: 5
                radius: 20
                samples: 20
                color: "#22000000"
            }
        }
    }

    StatusMacTrafficLights {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 13

        visible: Qt.platform.os == "osx"

        onClose: {
            rootWindow.close()
        }

        onMinimised: {
            rootWindow.showMinimized()
        }

        onMaximized: {
            rootWindow.toggleFullScreen()
        }
    }

    StatusWindowsTitleBar {
        anchors.top: parent.top
        width: parent.width

        visible: Qt.platform.os == "windows"

        onClose: {
            rootWindow.close()
        }

        onMinimised: {
            rootWindow.showMinimized()
        }

        onMaximized: {
            rootWindow.toggleFullScreen()
        }
    }
}

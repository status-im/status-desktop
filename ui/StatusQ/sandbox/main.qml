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
                            selected: page.sourceComponent == iconsComponent
                            onClicked: page.sourceComponent = iconsComponent
                        }

                        StatusListSectionHeadline { text: "StatusQ.Layout" }
                        StatusNavigationListItem { 
                            title: "Layouts" 
                            selected: page.sourceComponent == layoutComponent
                            onClicked: page.sourceComponent = layoutComponent
                        }

                        StatusListSectionHeadline { text: "StatusQ.Controls" }
                        StatusNavigationListItem { 
                            title: "Buttons" 
                            selected: page.sourceComponent == buttonsComponent
                            onClicked: page.sourceComponent = buttonsComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusSwitchTab" 
                            selected: page.sourceComponent == statusTabSwitchesComponent
                            onClicked: page.sourceComponent = statusTabSwitchesComponent
                        }
                        StatusNavigationListItem { 
                            title: "Controls" 
                            selected: page.sourceComponent == controlsComponent
                            onClicked: page.sourceComponent = controlsComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusInput" 
                            selected: page.sourceComponent == statusInputPageComponent
                            onClicked: page.sourceComponent = statusInputPageComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusSelect" 
                            selected: page.sourceComponent == statusSelectPageComponent
                            onClicked: page.sourceComponent = statusSelectPageComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusAccountSelector" 
                            selected: page.sourceComponent == statusAccountSelectorPageComponent
                            onClicked: page.sourceComponent = statusAccountSelectorPageComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusAssetSelector" 
                            selected: page.sourceComponent == statusAssetSelectorPageComponent
                            onClicked: page.sourceComponent = statusAssetSelectorPageComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusColorSelector" 
                            selected: page.sourceComponent == statusColorSelectorPageComponent
                            onClicked: page.sourceComponent = statusColorSelectorPageComponent
                        }
                        StatusListSectionHeadline { text: "StatusQ.Components" }
                        StatusNavigationListItem { 
                            title: "StatusAddress"
                            selected: page.sourceComponent == statusAddressPageComponent
                            onClicked: page.sourceComponent = statusAddressPageComponent
                        }
                        StatusNavigationListItem { 
                            title: "List Items"
                            selected: page.sourceComponent == listItemsComponent
                            onClicked: page.sourceComponent = listItemsComponent
                        }
                        StatusNavigationListItem { 
                            title: "StatusChatInfoToolBar"
                            selected: page.sourceComponent == chatInfoToolBarComponent
                            onClicked: page.sourceComponent = chatInfoToolBarComponent
                        }
                        StatusNavigationListItem { 
                            title: "Others"
                            selected: page.sourceComponent == othersComponent
                            onClicked: page.sourceComponent = othersComponent
                        }
                        StatusNavigationListItem {
                            title: "StatusExpandableItem"
                            selected: page.sourceComponent == settingsComponent
                            onClicked: page.sourceComponent = settingsComponent
                        }
                        StatusListSectionHeadline { text: "StatusQ.Popup" }
                        StatusNavigationListItem { 
                            title: "StatusPopupMenu"
                            selected: page.sourceComponent == popupMenuComponent
                            onClicked: page.sourceComponent = popupMenuComponent
                        }

                        StatusNavigationListItem {
                            title: "StatusModal"
                            selected: page.sourceComponent == statusModalComponent
                            onClicked: page.sourceComponent = statusModalComponent
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
                        height: Math.max(rootWindow.height, page.height + 128)
                        scale: rootWindow.factor
                        Loader {
                            id: page
                            active: true
                            anchors.centerIn: parent
                            sourceComponent: iconsComponent
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
        id: iconsComponent
        Icons { iconColor: Theme.palette.primaryColor1 }
    }

    Component {
        id: controlsComponent
        Controls {}
    }

    Component {
        id: statusInputPageComponent
        StatusInputPage {}
    }

    Component {
        id: statusSelectPageComponent
        StatusSelectPage {}
    }

    Component {
        id: statusAccountSelectorPageComponent
        StatusAccountSelectorPage {}
    }

    Component {
        id: statusAssetSelectorPageComponent
        StatusAssetSelectorPage {}
    }

    Component {
        id: statusColorSelectorPageComponent
        StatusColorSelectorPage {}
    }

    Component {
        id: listItemsComponent
        ListItems {}
    }

    Component {
        id: statusAddressPageComponent
        StatusAddressPage {}
    }

    Component {
        id: layoutComponent
        Layout {}
    }

    Component {
        id: othersComponent
        Others {}
    }

    Component {
        id: buttonsComponent
        Buttons {}
    }

    Component {
        id: popupMenuComponent
        StatusPopupMenuPage {}
    }

    Component {
        id: chatInfoToolBarComponent
        StatusChatInfoToolBarPage {}
    }

    Component {
        id: statusModalComponent
        Popups {}
    }

    Component {
        id: statusTabSwitchesComponent
        StatusTabSwitchPage {}
    }

    Component {
        id: settingsComponent
        StatusExpandableSettingsItemPage{}
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

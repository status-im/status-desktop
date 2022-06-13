import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.14
import Qt.labs.settings 1.0

import Sandbox 0.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Platform 0.1

import "demoapp/data" 1.0

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

    Component.onCompleted: rootWindow.updatePosition()

    QtObject {
        id: appSectionType
        readonly property int chat: 0
        readonly property int community: 1
        readonly property int wallet: 2
        readonly property int browser: 3
        readonly property int nodeManagement: 4
        readonly property int profileSettings: 5
        readonly property int apiDocumentation: 100
        readonly property int demoApp: 101
    }

    function setActiveItem(sectionId) {
        for (var i = 0; i < Models.mainAppSectionsModel.count; i++) {
            let item = Models.mainAppSectionsModel.get(i)
            if (item.sectionId !== sectionId) {
                Models.mainAppSectionsModel.setProperty(i, "active", false);
                continue
            }

            Models.mainAppSectionsModel.setProperty(i, "active", true);
        }
    }

    StatusAppLayout {
        id: appLayout
        anchors.fill: parent

        appNavBar: StatusAppNavBar {
            height: rootWindow.height

            communityTypeRole: "sectionType"
            communityTypeValue: appSectionType.community
            sectionModel: Models.mainAppSectionsModel

            regularNavBarButton: StatusNavBarTabButton {
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: model.name
                autoExclusive: true
                checked: model.active
                badge.value: model.notificationsCount
                badge.visible: model.hasNotification
                badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
                badge.border.width: 2
                onClicked: {
                    stackView.clear()
                    if(model.sectionType === appSectionType.apiDocumentation)
                    {
                        stackView.push(libraryDocumentationCmp)
                        rootWindow.setActiveItem(sectionId)
                    }
                    else if(model.sectionType === appSectionType.demoApp)
                    {
                        stackView.push(demoAppCmp)
                        rootWindow.setActiveItem(model.sectionId)
                    }
                }
            }
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
            lightThemeEnabled: storeSettings.lightTheme
            onLightThemeEnabledChanged: {
                Theme.palette = lightThemeEnabled ? rootWindow.darkTheme : rootWindow.lightTheme
                storeSettings.lightTheme = lightThemeEnabled
            }
        }
    }

    Component {
        id: libraryDocumentationCmp

        StatusAppTwoPanelLayout {
            id: mainPageView

            function page(name, fillPage) {
                storeSettings.fillPage = fillPage ? true : false
                viewLoader.source = Qt.resolvedUrl("./pages/" + name + "Page.qml");
            }
            function control(name) {
                viewLoader.source = Qt.resolvedUrl("./controls/" + name + ".qml");
                storeSettings.fillPage = false
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
                            title: "StatusTabBarButton"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
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
                        StatusNavigationListItem {
                            title: "StatusPasswordStrengthIndicator"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusPinInput"
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
                        StatusNavigationListItem {
                            title: "StatusTagSelector"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusToastMessage"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusWizardStepper"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusListPicker"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusCommunityCard"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusCommunityTags"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
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
                        StatusNavigationListItem {
                            title: "StatusDialog"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusListSectionHeadline { text: "StatusQ.Platform" }
                        StatusNavigationListItem {
                            title: "StatusMacNotification"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusColorSelectorGrid"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title);
                        }
                        StatusNavigationListItem {
                            title: "StatusImageCropPanel"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title, true);
                        }
                        StatusNavigationListItem {
                            title: "StatusColorSpace"
                            selected: viewLoader.source.toString().includes(title)
                            onClicked: mainPageView.page(title, true);
                        }
                    }
                }
            }

            rightPanel: Item {
                id: rightPanel
                anchors.fill: parent

                ScrollView {
                    visible: !storeSettings.fillPage
                    anchors.fill: parent
                    anchors.topMargin: 64
                    contentHeight: (pageWrapper.height + pageWrapper.anchors.topMargin) * rootWindow.factor
                    contentWidth: (pageWrapper.width * rootWindow.factor)
                    clip: true

                    Item {
                        id: pageWrapper
                        width: rightPanel.width
                        anchors.top: parent.top
                        height: Math.max(rootWindow.height, viewLoader.height + 128)
                        scale: rootWindow.factor

                        Loader {
                            id: viewLoader
                            active: !storeSettings.fillPage
                            anchors.centerIn: parent
                            source: storeSettings.selected.length === 0 ? mainPageView.control("Icons") : storeSettings.selected
                            onSourceChanged: {
                                storeSettings.selected = viewLoader.source
                                if (source.toString().includes("Icons")) {
                                    item.iconColor = Theme.palette.primaryColor1;
                                }
                            }
                        }
                    }
                }
                Loader {
                    active: storeSettings.fillPage
                    anchors.fill: parent
                    anchors.topMargin: 64
                    visible: storeSettings.fillPage
                    clip: true

                    source: viewLoader.source
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
                anchors.centerIn: parent
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

    Settings {
        id: storeSettings
        property string selected: ""
        property bool lightTheme: true
        property bool fillPage: false
    }
}

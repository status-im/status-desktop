import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import StatusQ 0.1 // https://github.com/status-im/status-desktop/issues/10218

import StatusQ.Core.Theme 0.1
import Storybook 1.0

import utils 1.0

ApplicationWindow {
    id: root

    width: 1450
    height: 840
    visible: true

    property string currentPage

    title: "%1 – %2".arg(currentPage).arg(Qt.application.displayName)

    palette.window: Theme.palette.statusAppLayout.backgroundColor
    palette.text: Theme.palette.directColor1
    palette.windowText: Theme.palette.directColor1
    palette.base: Theme.palette.indirectColor1
    font.pixelSize: 13

    onCurrentPageChanged: testsReRunTimer.restart()

    QtObject {
        id: d

        function activateInspection(item) {
            inspectionWindow.inspect(item)
            inspectionWindow.show()
            inspectionWindow.requestActivate()
        }

        function performInspection() {
            // Find the items to inspect on the current page
            const getItems = typeName =>
                           InspectionUtils.findItemsByTypeName(
                               viewLoader.item, typeName)
            const items = [
                ...getItems(root.currentPage),
                ...getItems("Custom" + root.currentPage)
            ]

            // Find lowest commont ancestor of found items
            const lca = InspectionUtils.lowestCommonAncestor(
                          items, viewLoader.item)

            // Inspect lca
            if (lca) {
                activateInspection(lca.parent.contentItem === lca
                                   ? lca.parent : lca)
                return
            }

            // Look for the item for inspection on the Overlay, skip items
            // without contentItem which can be, for example, instance of
            // Overlay.modal or Overlay.modeless
            const overlayChildren = root.Overlay.overlay.children

            for (let i = 0; i < overlayChildren.length; i++) {
                const item = overlayChildren[i]

                if (item.contentItem) {
                    activateInspection(item)
                    return
                }
            }

            nothingToInspectDialog.open()
        }
    }

    PagesModel {
        id: pagesModel
    }

    HotReloader {
        id: reloader

        loader: viewLoader
        enabled: hotReloaderControls.enabled

        onReloaded: {
            hotReloaderControls.notifyReload()
            testsReRunTimer.restart()
        }
    }

    TestRunnerController {
        id: testRunnerController
    }

    Timer {
        id: testsReRunTimer

        interval: 100

        onTriggered: {
            if (!settingsLayout.runTestsAutomatically)
                return

            const testFileName = `tst_${root.currentPage}.qml`
            const testsCount = testRunnerController.getTestsCount(testFileName)

            if (testsCount === 0)
                return

            testRunnerController.runTests(testFileName)
        }
    }

    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.preferredWidth: 270

            Pane {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    width: parent.width
                    height: parent.height

                    Button {
                        Layout.fillWidth: true

                        text: "Settings"

                        onClicked: settingsPopup.open()
                    }

                    CheckBox {
                        id: windowAlwaysOnTopCheckBox

                        Layout.fillWidth: true

                        text: "Always on top"
                        onCheckedChanged: {
                            if (checked)
                                root.flags |= Qt.WindowStaysOnTopHint
                            else
                                root.flags &= ~Qt.WindowStaysOnTopHint
                        }
                    }

                    CheckBox {
                        id: darkModeCheckBox

                        Layout.fillWidth: true

                        text: "Dark mode"
                        onCheckedChanged: Style.changeTheme(checked ? Universal.Dark : Universal.Light, !checked)
                    }

                    HotReloaderControls {
                        id: hotReloaderControls

                        Layout.fillWidth: true

                        onForceReloadClicked: reloader.forceReload()
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    FilteredPagesList {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        currentPage: root.currentPage
                        model: pagesModel

                        onPageSelected: root.currentPage = page
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Open pages directory"

                onClicked: Qt.openUrlExternally(Qt.resolvedUrl(pagesFolder))
            }
        }

        Page {
            SplitView.fillWidth: true

            Loader {
                id: viewLoader

                anchors.fill: parent
                clip: true

                source: `pages/${root.currentPage}Page.qml`
                asynchronous: settingsLayout.loadAsynchronously
                visible: status === Loader.Ready

                // force reload when `asynchronous` changes
                onAsynchronousChanged: {
                    active = false
                    active = true
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: viewLoader.status === Loader.Loading
            }

            Label {
                anchors.centerIn: parent
                visible: viewLoader.status === Loader.Error
                text: "Loading page failed"
            }

            footer: PageToolBar {
                id: pageToolBar

                componentName: root.currentPage
                figmaPagesCount: currentPageModelItem.object
                                 ? currentPageModelItem.object.figma.count : 0

                testRunnerController: testRunnerController

                Instantiator {
                    id: currentPageModelItem

                    model: SingleItemProxyModel {
                        sourceModel: pagesModel
                        roleName: "title"
                        value: root.currentPage
                    }

                    delegate: QtObject {
                        readonly property string title: model.title
                        readonly property var figma: model.figma
                    }
                }

                onFigmaPreviewClicked: {
                    if (!settingsLayout.figmaToken) {
                        noFigmaTokenDialog.open()
                        return
                    }

                    figmaWindow.createObject(root, {
                        figmaModel: currentPageModelItem.object.figma,
                        pageTitle: currentPageModelItem.object.title
                    })
                }

                onInspectClicked: d.performInspection()
            }
        }
    }

    Dialog {
        id: settingsPopup

        anchors.centerIn: Overlay.overlay
        width: 420
        modal: true

        header: Pane {
            background: null

            Label {
                text: "Settings"
            }
        }

        SettingsLayout {
            id: settingsLayout

            width: parent.width
        }
    }

    Dialog {
        id: noFigmaTokenDialog

        anchors.centerIn: Overlay.overlay

        title: "Figma token not set"
        standardButtons: Dialog.Ok

        Label {
            text: "Please set Figma personal token in \"Settings\""
        }
    }

    FigmaLinksCache {
        id: figmaImageLinksCache

        figmaToken: settingsLayout.figmaToken
    }

    InspectionWindow {
        id: inspectionWindow
    }

    Dialog {
        id: nothingToInspectDialog

        anchors.centerIn: Overlay.overlay
        width: contentItem.implicitWidth + leftPadding + rightPadding

        title: "No items to inspect found"
        standardButtons: Dialog.Ok
        modal: true

        contentItem: Label {
            text: '
Tips:\n\
    •   For inline components use naming convention of adding\n\
        "Custom" at the begining (like Custom'+root.currentPage+')\n\
    •   For popups set closePolicy to "Popup.NoAutoClose"\n\
'
        }
    }

    Component {
        id: figmaWindow

        FigmaPreviewWindow {
            property string pageTitle
            property alias figmaModel: figmaImagesProxyModel.sourceModel

            title: pageTitle + " - Figma"

            model: FigmaImagesProxyModel {
                id: figmaImagesProxyModel

                figmaLinksCache: figmaImageLinksCache
            }

            onClosing: Qt.callLater(destroy)
        }
    }

    Settings {
        id: settings

        property alias currentPage: root.currentPage
        property alias loadAsynchronously: settingsLayout.loadAsynchronously
        property alias runTestsAutomatically: settingsLayout.runTestsAutomatically
        property alias darkMode: darkModeCheckBox.checked
        property alias hotReloading: hotReloaderControls.enabled
        property alias figmaToken: settingsLayout.figmaToken
        property alias windowAlwaysOnTop: windowAlwaysOnTopCheckBox.checked
    }

    Shortcut {
        sequence: "Ctrl+Shift+I"
        context: Qt.ApplicationShortcut
        onActivated: d.performInspection()
    }
}

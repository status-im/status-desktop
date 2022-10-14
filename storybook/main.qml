import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1
import Storybook 1.0

ApplicationWindow {
    id: root

    width: 1450
    height: 840
    visible: true

    property string currentPage

    font.pixelSize: 13

    ListModel {
        id: pagesModel

        ListElement {
             title: "CommunitiesPortalLayout"
        }
        ListElement {
             title: "LoginView"
        }
    }

    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.preferredWidth: 240

            CheckBox {
                id: loadAsyncCheckBox

                Layout.fillWidth: true

                text: "Load asynchronously"
            }

            CheckBox {
                id: darkModeCheckBox

                Layout.fillWidth: true

                text: "Dark mode"

                StatusLightTheme { id: lightTheme }
                StatusDarkTheme { id: darkTheme }

                Binding {
                    target: Theme
                    property: "palette"
                    value: darkModeCheckBox.checked ? darkTheme : lightTheme
                }
            }

            Pane {
                Layout.fillWidth: true
                Layout.fillHeight: true

                PagesList {
                    anchors.fill: parent

                    currentPage: root.currentPage
                    model: pagesModel

                    onPageSelected: root.currentPage = page
                }
            }
        }

        Item {
            SplitView.fillWidth: true

            Loader {
                id: viewLoader

                anchors.fill: parent
                clip: true

                source: Qt.resolvedUrl(`./pages/${root.currentPage}Page.qml`)
                asynchronous: loadAsyncCheckBox.checked
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
        }
    }

    Settings {
        property alias currentPage: root.currentPage
        property alias loadAsynchronously: loadAsyncCheckBox.checked
        property alias darkMode: darkModeCheckBox.checked
    }
}

import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1

import Qt.labs.settings 1.0


ApplicationWindow {
    id: rootWindow

    width: 1450
    height: 840
    visible: true

    StatusSectionLayout {
        id: mainPageView

        anchors.fill: parent
        showHeader: false

        function page(name, fillPage) {
            viewLoader.source = Qt.resolvedUrl("./pages/" + name + "Page.qml");
            storeSettings.selected = viewLoader.source
        }

        leftPanel: StatusScrollView {
            anchors.fill: parent
            anchors.topMargin: 48

            Column {
                id: navigation
                spacing: 0

                StatusNavigationListItem {
                    title: "CommunitiesPortalLayout"
                    selected: viewLoader.source.toString().includes(title)
                    onClicked: mainPageView.page(title);
                }
            }
        }

        centerPanel: Item {
            id: centerPanel
            anchors.fill: parent

            Loader {
                id: viewLoader
                anchors.fill: parent
                clip: true
                source: storeSettings.selected
            }
        }
    }

    Settings {
        id: storeSettings
        property string selected: ""
    }
}

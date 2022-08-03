import QtQml
import QtQuick
import QtQuick.Layouts

import Status.Controls.Navigation


/// Template for side NavigationBar
///
/// The width is given, the rest of the controls have to adapt to the width
/// Contains a list of 
Item {
    id: root

    implicitWidth: 78
    implicitHeight: mainLayout.implicitHeight

    property alias currentIndex: listView.currentIndex

    required property var sections

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        MacTrafficLights {
            Layout.margins: 13
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.sections

            // TODO: sync with user settings
            currentIndex: 0

            onCurrentItemChanged: currentItem.item.selected = true

            // Each delegate is a section
            delegate: Loader {
                property var content: modelData.content
                sourceComponent: modelData.navigationSection
                Connections {
                    target: item
                    function onSelectedChanged() {
                        listView.currentIndex = index
                    }
                }
            }
        }
    }
}

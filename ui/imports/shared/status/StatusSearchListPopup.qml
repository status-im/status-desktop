import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Popup {
    id: root

    anchors.centerIn: Overlay.overlay

    width: 400
    height: 300

    property alias model: listView.model

    // delegate interface has to be fulfilled
    property Component delegate: Item {
        property var modelData
        property bool isCurrentItem
        function filterAccepts(searchText) {
            return true
        }
    }
    property string searchBoxPlaceholder: qsTr("Search...")

    signal selected(int index, var modelData)

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    ColumnLayout {
        anchors.fill: parent

        StatusInput {
            id: searchBox

            Layout.fillWidth: true
            leftPadding: 0
            rightPadding: 0
            placeholderText: root.searchBoxPlaceholder
            input.asset.name: "search"

            function goToNextAvailableIndex(up) {
                var currentIndex = listView.currentIndex
                for (var i = 0; i < listView.count; i++) {
                    currentIndex = up ? (currentIndex === 0 ? listView.count - 1 : currentIndex - 1)
                                      : (currentIndex === listView.count - 1 ? 0 : currentIndex + 1)
                    listView.currentIndex = currentIndex
                    if (listView.currentItem.visible) {
                        return
                    }
                }
                listView.currentIndex = 0
            }

            Keys.onReleased: {
                listView.selectByHover = false

                if (event.key === Qt.Key_Down) {
                    searchBox.goToNextAvailableIndex(false)
                }
                if (event.key === Qt.Key_Up) {
                    searchBox.goToNextAvailableIndex(true)
                }
                if (event.key === Qt.Key_Escape) {
                    return root.close()
                }
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    return root.selected(listView.currentIndex,
                                         listView.currentItem.myData)
                }
                if (!listView.currentItem.visible) {
                    goToNextAvailableIndex(false)
                }
            }

            onTextChanged: if (text === "") listView.currentIndex = 0
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            property bool selectByHover: false

            highlightMoveDuration: 200

            delegate: Item {
                id: delegateItem

                property var myData: typeof modelData === "undefined" ? model : modelData

                width: listView.width
                height: visible ? delegateLoader.height : 0

                Loader {
                    id: delegateLoader

                    width: parent.width
                    sourceComponent: root.delegate

                    onLoaded: {
                        item.modelData = delegateItem.myData
                        item.isCurrentItem = Qt.binding(() => delegateItem.ListView.isCurrentItem)
                        delegateItem.visible = Qt.binding(() => item.filterAccepts(searchBox.text))
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onClicked: (mouse) => {
                                   listView.currentIndex = index
                                   root.selected(index, delegateItem.myData)
                                   mouse.accepted = false
                               }
                    onContainsMouseChanged: if (containsMouse) listView.currentIndex = index
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Loader {
                anchors.fill: parent
                active: !listView.selectByHover

                sourceComponent: MouseArea {
                    hoverEnabled: true
                    onPositionChanged: listView.selectByHover = true
                }
            }
        }
    }

    onAboutToShow: {
        listView.currentIndex = 0
        listView.selectByHover = false
        searchBox.text = ""
        searchBox.input.edit.forceActiveFocus()
    }

    onClosed: {
        root.destroy();
    }
}

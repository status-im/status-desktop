import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2
import utils 1.0

Popup {
    id: root

    anchors.centerIn: Overlay.overlay

    width: 400
    height: 300

    required property var model

    property string searchBoxPlaceholder: qsTr("Search...")

    signal selected(string sectionId, string chatId)

    background: Rectangle {
        radius: Theme.radius
        color: Theme.palette.background
        border.color: Theme.palette.border
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
                    return listView.currentItem.selectThisItem()
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

            model: SortFilterProxyModel {
                sourceModel: root.model

                filters: AnyOf {
                    SearchFilter {
                        roleName: "sectionName"
                        searchPhrase: searchBox.text
                    }
                    SearchFilter {
                        roleName: "name"
                        searchPhrase: searchBox.text
                    }
                    enabled: !!searchBox.text
                }
                sorters: StringSorter {
                    roleName: "name"
                }
            }

            delegate: StatusListItem {
                id: listItem

                function selectThisItem() {
                    root.selected(model.sectionId, model.chatId)
                }

                title: model ? model.name : ""
                label: model? model.sectionName : ""
                highlighted: ListView.isCurrentItem
                width: ListView.view.width
                sensor.hoverEnabled: false
                statusListItemIcon {
                    name: model ? model.name : ""
                    active: true
                }
                asset.width: 30
                asset.height: 30
                asset.color: model ? model.color ? model.color : Utils.colorForColorId(model.colorId) : ""
                asset.name: model ? model.icon : ""
                asset.emoji: model ? model.emoji : ""
                asset.charactersLen: 2
                asset.letterSize: asset._twoLettersSize
                ringSettings.ringSpecModel: model ? model.colorHash : undefined

                StatusMouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onClicked: (mouse) => {
                                listView.currentIndex = index
                                listItem.selectThisItem()
                                mouse.accepted = false
                            }
                    onContainsMouseChanged: if (containsMouse) listView.currentIndex = index
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Loader {
                anchors.fill: parent
                active: !listView.selectByHover

                sourceComponent: StatusMouseArea {
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
}

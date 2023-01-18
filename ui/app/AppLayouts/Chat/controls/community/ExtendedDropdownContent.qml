import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

import shared.controls 1.0
import shared.panels 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property var store
    property int type: ExtendedDropdownContent.Type.Assets

    readonly property bool canGoBack: root.state !== d.listView_depth1_State

    signal itemClicked(string key, string name, url iconSource)
    signal navigateDeep(string key, var subItems)

    enum Type{
        Assets,
        Collectibles
    }

    function goBack() {
        root.state = d.listView_depth1_State
    }

    function goForward(key, itemName, itemSource, subItems) {
        d.currentSubitems = subItems
        d.currentItemKey = key
        d.currentItemName = itemName
        d.currentItemSource = itemSource
        root.state = d.listView_depth2_State
    }

    QtObject {
        id: d
        readonly property int filterItemsHeight: 36
        readonly property int filterPopupWidth: 233
        readonly property int filterPopupHeight: 205

        // Internal management properties
        property bool isFilterOptionVisible: false
        readonly property string thumbnailsViewState: "THUMBNAILS"
        readonly property string listView_depth1_State: "LIST-DEPTH1"
        readonly property string listView_depth2_State: "LIST-DEPTH2"
        property var currentModel: root.store.collectiblesModel
        property var currentSubitems
        property string currentItemKey: ""
        property string currentItemName: ""
        property url currentItemSource: ""

        readonly property SortFilterProxyModel filtered: SortFilterProxyModel {
            id: collectiblesFilteredModel

            sourceModel: root.store.collectiblesModel

            filters: ExpressionFilter {
                expression: {
                    searcher.text
                    return name.toLowerCase().includes(searcher.text.toLowerCase())
                }
            }
        }

        function reset() {
            d.currentItemKey = ""
            d.currentItemName = ""
            d.currentItemSource = ""
            d.currentModel = root.store.collectiblesModel
            d.currentSubitems = undefined
            root.state = d.listView_depth1_State
        }
    }

    state: d.listView_depth1_State
    states: [
        State {
            name: d.listView_depth1_State

            PropertyChanges {
                target: contentLoader
                sourceComponent: root.type === ExtendedDropdownContent.Type.Assets
                                 ? assetsListView : collectiblesListView
            }
            PropertyChanges {
                target: d
                currentModel: root.type === ExtendedDropdownContent.Type.Assets
                              ? root.store.assetsModel : collectiblesFilteredModel//root.store.collectiblesModel
                isFilterOptionVisible: false
            }
            PropertyChanges {
                target: tokenGroupItem
                visible: false
            }
            PropertyChanges {
                target: searcher
                visible: type === ExtendedDropdownContent.Type.Collectibles
            }
        },
        State {
            name: d.listView_depth2_State

            PropertyChanges {
                target: contentLoader
                sourceComponent: collectiblesListView
            }
            PropertyChanges {
                target: d
                currentModel: d.currentSubitems
                isFilterOptionVisible: true
            }
            PropertyChanges {
                target: tokenGroupItem
                visible: true
            }
        },
        State {
            name: d.thumbnailsViewState

            PropertyChanges {
                target: contentLoader
                sourceComponent: thumbnailsView
            }
            PropertyChanges {
                target: d
                currentModel: d.currentSubitems
                isFilterOptionVisible: true
            }
            PropertyChanges {
                target: tokenGroupItem
                visible: true
            }
        }
    ]

    StatusFlatRoundButton {
        id: filterButton
        width: 32
        height: 32
        visible: d.isFilterOptionVisible
        type: StatusFlatRoundButton.Type.Secondary
        icon.name: "filter"

        anchors.right: parent.right
        anchors.bottom: parent.top
        anchors.bottomMargin: 3

        onClicked: {
            filterOptionsPopup.x = filterButton.x + filterButton.width - filterOptionsPopup.width
            filterOptionsPopup.y = filterButton.y + filterButton.height + 8
            filterOptionsPopup.open()
        }
    }

    // Filter options popup:
    StatusDropdown {
        id: filterOptionsPopup
        width: d.filterPopupWidth
        height: d.filterPopupHeight
        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: model.count * d.filterItemsHeight
                model: ListModel {
                    ListElement { text: qsTr("Most viewed"); selected: true }
                    ListElement { text: qsTr("Newest first"); selected: false }
                    ListElement { text: qsTr("Oldest first"); selected: false }
                }
                delegate: StatusItemPicker {
                    width: ListView.view.width
                    height: d.filterItemsHeight
                    color: sensor1.containsMouse ? Theme.palette.baseColor4 : "transparent"
                    name: model.text
                    namePixelSize: 13
                    selectorType: StatusItemPicker.SelectorType.RadioButton
                    radioGroup: filterRadioBtnGroup
                    radioButtonSize: StatusRadioButton.Size.Small
                    selected: model.selected

                    MouseArea {
                        id: sensor1
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            selected = !selected
                            console.log("TODO: Clicked filter option: " + model.text)
                            filterOptionsPopup.close()
                        }
                    }
                }

                // Not visual element to control filter options
                ButtonGroup {
                    id: filterRadioBtnGroup
                }
            }

            Separator { Layout.fillWidth: true }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: model.count * d.filterItemsHeight
                model: ListModel {
                    ListElement { key: "LIST"; text: qsTr("List"); selected: true }
                    ListElement { key: "THUMBNAILS"; text: qsTr("Thumbnails"); selected: false }
                }
                delegate:  StatusItemPicker {
                    width: ListView.view.width
                    height: d.filterItemsHeight
                    color: sensor2.containsMouse ? Theme.palette.baseColor4 : "transparent"
                    name: model.text
                    namePixelSize: 13
                    selectorType: StatusItemPicker.SelectorType.RadioButton
                    radioGroup: visualizationRadioBtnGroup
                    radioButtonSize: StatusRadioButton.Size.Small
                    selected: model.selected

                    MouseArea {
                        id: sensor2
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            selected = !selected
                            if(model.key === "LIST") {
                                root.state = d.listView_depth2_State
                            }
                            else if(model.key === "THUMBNAILS") {
                                 root.state = d.thumbnailsViewState
                            }
                            filterOptionsPopup.close()
                        }
                    }
                }

                // Not visual element to control visualization options
                ButtonGroup {
                    id: visualizationRadioBtnGroup
                }
            }
        }
    }

    // List elements content

    ColumnLayout {
        anchors.fill: parent

        SearchBox {
            id: searcher

            Layout.fillWidth: true

            visible: false
            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36
            maximumHeight: 36
        }

        TokenItem {
           id: tokenGroupItem
           Layout.fillWidth: true
           key: d.currentItemKey
           name: d.currentItemName
           iconSource: d.currentItemSource
           enabled: true
           onItemClicked: root.itemClicked(d.currentItemKey,
                                           d.currentItemName,
                                           d.currentItemSource)
        }

        Loader {
            id: contentLoader

            Layout.fillWidth: true
            Layout.fillHeight: true

        }
    }

    Component {
        id: assetsListView

        ListDropdownContent {
            headerModel: ListModel {
                ListElement { key: "MINT"; icon: "add"; iconSize: 16; description: qsTr("Mint asset"); rotation: 0; spacing: 8 }
                ListElement { key: "IMPORT"; icon: "invite-users"; iconSize: 16; description: qsTr("Import existing asset"); rotation: 180; spacing: 8 }
            }
            isHeaderVisible: false  // TEMPORARILY hidden. These 2 header options will be implemented after MVP.
            model: d.currentModel
            onHeaderItemClicked: {
                if(key === "MINT") console.log("TODO: Mint asset")
                else if(key === "IMPORT") console.log("TODO: Import existing asset")
            }
            onItemClicked: root.itemClicked(key, shortName, iconSource)
        }
    }

    Component {
        id: collectiblesListView

        ListDropdownContent {
            isHeaderVisible: root.state === d.listView_depth1_State
            headerModel: ListModel {
               ListElement { key: "MINT"; icon: "add"; iconSize: 16; description: qsTr("Mint collectible"); rotation: 0; spacing: 8 }
            }

            model: d.currentModel

            onHeaderItemClicked: {
                if(key === "MINT") console.log("TODO: Mint collectible")
            }
            onItemClicked: {
                if(subItems && root.state === d.listView_depth1_State) {
                    // One deep navigation
                    d.currentSubitems = subItems
                    d.currentItemKey = key
                    d.currentItemName = name
                    d.currentItemSource = iconSource
                    root.state = d.listView_depth2_State
                    root.navigateDeep(key, subItems)
                }
                else {
                    d.reset()
                    root.itemClicked(key, name, iconSource)
                }
            }
        }
    }

    Component {
        id: thumbnailsView

        ThumbnailsDropdownContent {
            title: d.currentItemName
            titleImage: d.currentItemSource

            padding: 0

            model: d.currentModel
            onItemClicked: {
                d.reset()
                root.itemClicked(key, name, iconSource)
            }
        }
    }
}

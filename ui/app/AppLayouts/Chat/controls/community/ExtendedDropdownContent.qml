import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml 2.14

import Qt.labs.settings 1.0

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
    property var checkedKeys: []
    property int type: ExtendedDropdownContent.Type.Assets

    readonly property bool canGoBack: root.state !== d.depth1_ListState

    signal itemClicked(string key, string name, url iconSource)
    signal navigateDeep(string key, var subItems)

    enum Type{
        Assets,
        Collectibles
    }

    function goBack() {
        d.reset()
    }

    function goForward(key, itemName, itemSource, subItems) {
        d.currentSubitems = subItems
        d.currentItemKey = key
        d.currentItemName = itemName
        d.currentItemSource = itemSource
        root.state = d.useThumbnailsOnDepth2
                ? d.depth2_ThumbnailsState : d.depth2_ListState
    }

    Settings {
        property alias useThumbnailsOnDepth2: d.useThumbnailsOnDepth2
    }

    QtObject {
        id: d

        readonly property int filterItemsHeight: 36
        readonly property int filterPopupWidth: 233

        // Internal management properties
        property bool isFilterOptionVisible: false
        property bool useThumbnailsOnDepth2: false

        readonly property string depth1_ListState: "DEPTH-1-LIST"
        readonly property string depth2_ListState: "DEPTH-2-LIST"
        readonly property string depth2_ThumbnailsState: "DEPTH-2-THUMBNAILS"

        property var currentModel: null
        property var currentSubitems: null
        property string currentItemKey: ""
        property string currentItemName: ""
        property url currentItemSource: ""

        readonly property bool searchMode: searcher.text.length > 0

        onCurrentModelChanged: {
            // Workaround for a bug in SortFilterProxyModel causing that model
            // is rendered incorrectly when sourceModel is changed to a model
            // with different set of roles
            filteredModel.active = false
            filteredModel.active = true

            searcher.text = ""
            filteredModel.item.sourceModel = currentModel
            contentLoader.item.model = filteredModel.item
        }

        readonly property Loader loader_: Loader {
            id: filteredModel

            sourceComponent: SortFilterProxyModel {
                filters: ExpressionFilter {
                    expression: {
                        searcher.text

                        if (model.shortName && model.shortName.toLowerCase()
                                .includes(searcher.text.toLowerCase()))
                            return true

                        return model.name.toLowerCase().includes(
                                    searcher.text.toLowerCase())
                    }
                }
            }
        }

        function reset() {
            searcher.text = ""
            d.currentItemKey = ""
            d.currentItemName = ""
            d.currentItemSource = ""
            d.currentSubitems = null
            root.state = d.depth1_ListState
        }
    }

    state: d.depth1_ListState
    states: [
        State {
            name: d.depth1_ListState

            PropertyChanges {
                target: contentLoader
                sourceComponent: root.type === ExtendedDropdownContent.Type.Assets
                                 ? assetsListView : collectiblesListView
            }
            PropertyChanges {
                target: d
                currentModel: root.type === ExtendedDropdownContent.Type.Assets
                              ? root.store.assetsModel : root.store.collectiblesModel
                isFilterOptionVisible: false
            }

            PropertyChanges {
                target: tokenGroupItem
                visible: false
            }
        },
        State {
            name: d.depth2_ListState

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
            name: d.depth2_ThumbnailsState

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

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8

            spacing: 0

            // TODO: it can be simplified by using inline components after
            // migration to Qt 5.15 or higher
            Repeater {
                model: ListModel {
                    ListElement { text: qsTr("Most viewed"); selected: true }
                    ListElement { text: qsTr("Newest first"); selected: false }
                    ListElement { text: qsTr("Oldest first"); selected: false }
                }

                delegate: StatusItemPicker {
                    Layout.fillWidth: true
                    Layout.preferredHeight: d.filterItemsHeight

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
            }

            ButtonGroup {
                id: filterRadioBtnGroup
            }

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            Repeater {
                model: ListModel {
                    ListElement { key: "LIST"; text: qsTr("List"); selected: true }
                    ListElement { key: "THUMBNAILS"; text: qsTr("Thumbnails"); selected: false }
                }

                delegate: StatusItemPicker {
                    Layout.fillWidth: true
                    Layout.preferredHeight: d.filterItemsHeight

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
                                root.state = d.depth2_ListState
                            }
                            else if(model.key === "THUMBNAILS") {
                                 root.state = d.depth2_ThumbnailsState
                            }
                            filterOptionsPopup.close()
                        }
                    }

                    Binding {
                        target: d
                        when: model.key === "THUMBNAILS" && selected
                        property: "useThumbnailsOnDepth2"
                        value: true
                        restoreMode: Binding.RestoreBindingOrValue
                    }
                }
            }

            ButtonGroup {
                id: visualizationRadioBtnGroup
            }
        }
    }

    // List elements content

    ColumnLayout {
        anchors.fill: parent

        SearchBox {
            id: searcher

            Layout.fillWidth: true
            Layout.topMargin: root.state === d.depth1_ListState ? 0 : 8

            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36
            maximumHeight: 36

            placeholderText: root.type === ExtendedDropdownContent.Type.Assets ?
                                 qsTr("Search assets") : qsTr("Search collectibles")

            Binding on placeholderText{
                when: d.currentItemName !== ""
                value: qsTr("Search %1").arg(d.currentItemName)
            }
        }

        TokenItem {
           id: tokenGroupItem

           Layout.fillWidth: true

           key: d.currentItemKey
           name: qsTr("Any %1").arg(d.currentItemName)
           iconSource: d.currentItemSource

           selected: root.checkedKeys.includes(key)
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
            areHeaderButtonsVisible: false  // TEMPORARILY hidden. These 2 header options will be implemented after MVP.
            checkedKeys: root.checkedKeys
            searchMode: d.searchMode

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
            areHeaderButtonsVisible: root.state === d.depth1_ListState
            headerModel: ListModel {
               ListElement { key: "MINT"; icon: "add"; iconSize: 16; description: qsTr("Mint collectible"); rotation: 0; spacing: 8 }
            }

            checkedKeys: root.checkedKeys
            searchMode: d.searchMode

            onHeaderItemClicked: {
                if(key === "MINT") console.log("TODO: Mint collectible")
            }
            onItemClicked: {
                if(subItems && root.state === d.depth1_ListState) {
                    // One deep navigation
                    d.currentSubitems = subItems
                    d.currentItemKey = key
                    d.currentItemName = name
                    d.currentItemSource = iconSource
                    root.state = d.useThumbnailsOnDepth2
                            ? d.depth2_ThumbnailsState : d.depth2_ListState
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
            checkedKeys: root.checkedKeys

            padding: 0

            onItemClicked: {
                d.reset()
                root.itemClicked(key, name, iconSource)
            }
        }
    }
}

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

    property var assetsModel
    property var collectiblesModel

    property var checkedKeys: []
    property int type: ExtendedDropdownContent.Type.Assets

    property string noDataText: qsTr("No data found")
    property bool showAllTokensMode: false

    readonly property bool canGoBack: root.state !== d.depth1_ListState

    signal itemClicked(string key, string name, url iconSource)
    signal footerButtonClicked

    signal navigateDeep(string key, var subItems)

    signal layoutChanged()
    signal navigateToMintTokenSettings

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    onShowAllTokensModeChanged: searcher.text = ""

    enum Type {
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

    onFocusChanged: {
        if(focus)
            searcher.forceActiveFocus()
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
        readonly property bool availableData: {
            if(root.type === ExtendedDropdownContent.Type.Assets && root.assetsModel && root.assetsModel.count > 0)
                return true
            if(root.type === ExtendedDropdownContent.Type.Collectibles && root.collectiblesModel && root.collectiblesModel.count > 0)
                return true
            return false
        }

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
                filters: [
                    ValueFilter {
                        roleName: "category"
                        value: TokenCategories.Category.General
                        inverted: true
                        enabled: !root.showAllTokensMode
                    },
                    AnyOf {
                        enabled: root.showAllTokensMode

                        ValueFilter {
                            roleName: "category"
                            value: TokenCategories.Category.Own
                        }

                        ValueFilter {
                            roleName: "category"
                            value: TokenCategories.Category.General
                        }
                    },
                    ExpressionFilter {
                        expression: {
                            searcher.text

                            if (model.shortName && model.shortName.toLowerCase()
                                    .includes(searcher.text.toLowerCase()))
                                return true

                            return model.name.toLowerCase().includes(
                                        searcher.text.toLowerCase())
                        }
                    }
                ]

                proxyRoles: ExpressionRole {
                    name: "categoryLabel"

                    function getCategoryLabelForType(category, type) {
                        if (type === ExtendedDropdownContent.Type.Assets)
                            return TokenCategories.getCategoryLabelForAsset(category)

                        return TokenCategories.getCategoryLabelForCollectible(category)
                    }

                    expression: getCategoryLabelForType(model.category, root.type)
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

    onStateChanged: forceActiveFocus()

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
                              ? root.assetsModel : root.collectiblesModel
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
        id: content
        anchors.fill: parent

        SearchBox {
            id: searcher

            Layout.fillWidth: true
            Layout.topMargin: root.state === d.depth1_ListState ? 0 : 8

            visible: d.availableData
            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36
            maximumHeight: 36

            placeholderText: {
                if (root.type === ExtendedDropdownContent.Type.Assets) {
                    if (root.showAllTokensMode)
                        return qsTr("Search all listed assets")

                    return qsTr("Search assets")
                }

                if (root.showAllTokensMode)
                    return qsTr("Search all collectibles")

                return qsTr("Search collectibles")
            }

            KeyNavigation.backtab: searcher

            Binding on placeholderText {
                when: d.currentItemName !== ""
                value: qsTr("Search %1").arg(d.currentItemName)
            }
            onVisibleChanged: {
                if(visible)
                    forceActiveFocus()
            }
            Component.onCompleted: {
                if(visible)
                    forceActiveFocus()
            }
        }

        TokenItem {
           id: tokenGroupItem

           Layout.fillWidth: true

           name: qsTr("Any %1").arg(d.currentItemName)
           iconSource: d.currentItemSource

           selected: root.checkedKeys.includes(d.currentItemKey)
           enabled: true
           onItemClicked: root.itemClicked(d.currentItemKey,
                                           d.currentItemName,
                                           d.currentItemSource)
        }

        Loader {
            id: contentLoader

            Layout.fillWidth: true
            Layout.fillHeight: true
            onItemChanged: root.layoutChanged()
        }
    }

    Component {
        id: assetsListView

        ListDropdownContent {
            availableData: d.availableData
            noDataText: root.noDataText
            areHeaderButtonsVisible: root.state === d.depth1_ListState
                                     && !root.showAllTokensMode
            headerModel: ListModel {
               ListElement {
                   key: "MINT"
                   icon: "add"
                   iconSize: 16
                   description: qsTr("Mint asset")
                   rotation: 0
                   spacing: 8
               }
            }
            checkedKeys: root.checkedKeys
            searchMode: d.searchMode

            footerButtonText: TokenCategories.getCategoryLabelForAsset(
                                  TokenCategories.Category.General)

            areSectionsVisible: !root.showAllTokensMode
            isFooterButtonVisible: !root.showAllTokensMode && !d.searchMode
                                   && filteredModel.item && d.currentModel.count > filteredModel.item.count

            onHeaderItemClicked: root.navigateToMintTokenSettings()
            onFooterButtonClicked: root.footerButtonClicked()

            onItemClicked: root.itemClicked(key, shortName, iconSource)

            onImplicitHeightChanged: root.layoutChanged()

            Binding on implicitHeight {
                value: contentHeight
                //avoid too many changes of the implicit height
                delayed: true
            }
        }
    }

    Component {
        id: collectiblesListView

        ListDropdownContent {
            availableData: d.availableData
            noDataText: root.noDataText
            areHeaderButtonsVisible: root.state === d.depth1_ListState
                                     && !root.showAllTokensMode
            headerModel: ListModel {
               ListElement {
                   key: "MINT"
                   icon: "add"
                   iconSize: 16
                   description: qsTr("Mint collectible")
                   rotation: 0
                   spacing: 8
               }
            }

            checkedKeys: root.checkedKeys
            searchMode: d.searchMode

            footerButtonText: TokenCategories.getCategoryLabelForCollectible(
                                  TokenCategories.Category.General)

            areSectionsVisible: !root.showAllTokensMode
            isFooterButtonVisible: !root.showAllTokensMode && !d.searchMode
                                   && filteredModel.item && d.currentModel
                                   && d.currentModel.count > filteredModel.item.count

            onHeaderItemClicked: root.navigateToMintTokenSettings()
            onFooterButtonClicked: root.footerButtonClicked()

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
            onImplicitHeightChanged: root.layoutChanged()
            Binding on implicitHeight {
                value: contentHeight
                //avoid too many changes of the implicit height
                delayed: true
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
            onImplicitHeightChanged: root.layoutChanged()
        }
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import utils 1.0

import AppLayouts.Profile.controls 1.0

DoubleFlickableWithFolding {
    id: root

    readonly property var showcaseRoles: ["showcaseVisibility", "order"]

    required property string keyRole
    required property var roleNames
    required property var filterFunc

    property var baseModel
    property var showcaseModel

    property Component showcaseDraggableDelegateComponent
    property Component hiddenDraggableDelegateComponent

    property Component additionalFooterComponent

    property string emptyInShowcasePlaceholderText
    property string emptyHiddenPlaceholderText

    readonly property Connections showcaseUpdateConnections: Connections {
        target: root.showcaseModel

        function onBaseModelFilterConditionsMayHaveChanged() {
            root.updateBaseModelFilters()
        }
    }

    function reset() {
        root.showcaseModel.clear()
        updateBaseModelFilters()
    }

    function updateBaseModelFilters() {
        // Reset base model to update filter conditions
        hiddenListView.model = null
        hiddenListView.model = root.baseModel
    }

    signal showcaseEntryChanged()

    QtObject {
        id: d

        readonly property var dragHiddenItemKey: ["x-status-draggable-showcase-item-hidden"]
        readonly property var dragShowcaseItemKey: ["x-status-draggable-showcase-item"]

        property bool isAnyShowcaseDragActive: false
        property bool isAnyHiddenDragActive: false

        property int additionalHeaderComponentWidth: 350 // by design
        property int additionalHeaderComponentHeight: 40 // by design
    }

    clip: true

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

    flickable1: EmptyShapeRectangleFooterListView {
        id: inShowcaseListView

        model: root.showcaseModel
        width: root.width
        placeholderText: root.emptyInShowcasePlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !dropAreaRow.visible
        spacing: Style.current.halfPadding

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("In showcase")
            folded: root.flickable1Folded
            rightAdditionalComponent: VisibilityDropAreaButtonsRow {
                width: d.additionalHeaderComponentWidth
                height: d.additionalHeaderComponentHeight
                margins: 0
                visible: root.flickable1Folded &&
                         (d.isAnyHiddenDragActive ||
                          parent.containsDrag ||
                          everyoneContainsDrag ||
                          contactsContainsDrag ||
                          verifiedContainsDrag)
            }

            onToggleFolding: root.flip1Folding()
        }

        delegate: DropArea {
            id: showcaseDelegateRoot

            property int visualIndex: index

            width: ListView.view.width
            height: visible && showcaseDraggableDelegateLoader.item ? showcaseDraggableDelegateLoader.item.height : 0

            keys: d.dragShowcaseItemKey
            visible: model.showcaseVisibility !== Constants.ShowcaseVisibility.NoOne

            onEntered: function(drag) {
                const from = drag.source.visualIndex
                const to = showcaseDraggableDelegateLoader.item.visualIndex
                if (to === from)
                    return
                root.showcaseEntryChanged()
                root.showcaseModel.move(from, to, 1)
                drag.accept()
            }

            // TODO:
            // This animation is causing issues when there are no elements in the showcase list.
            // Reenable it once the refactor of the models and delegates is done (simplified): #13498
            // ListView.onRemove: SequentialAnimation {
            //  PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: true }
            //      NumberAnimation { target: showcaseDelegateRoot; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
            //      PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: false }
            // }

            // In showcase delegate item container:
            Loader {
                id: showcaseDraggableDelegateLoader

                property var modelData: model
                property var dragParentData: root
                property int visualIndexData: index

                width: parent.width
                sourceComponent: root.showcaseDraggableDelegateComponent
            }

            // Delegate shadow background when dragging:
            ShadowDelegate {
                id: showcaseShadow

                visible: showcaseDraggableDelegateLoader.item && showcaseDraggableDelegateLoader.item.dragActive
                onVisibleChanged: d.isAnyShowcaseDragActive = visible
            }

            Binding {
                when: dropAreaRow.visible
                target: showcaseDraggableDelegateLoader.item
                property: "blurState"
                value: true
                restoreMode: Binding.RestoreBindingOrValue
            }
        }

        // Overlaid showcase listview content drop area:
        DropArea {
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.contentHeight
            keys: d.dragHiddenItemKey

            // Shown at the bottom of the listview
            VisibilityDropAreaButtonsRow {
                id: dropAreaRow

                width: parent.width
                height: ProfileUtils.defaultDelegateHeight
                anchors.bottom: parent.bottom
                visible: d.isAnyHiddenDragActive ||
                         parent.containsDrag ||
                         everyoneContainsDrag ||
                         contactsContainsDrag ||
                         verifiedContainsDrag
            }
        }
    }

    flickable2: EmptyShapeRectangleFooterListView {
        id: hiddenListView

        model: root.baseModel
        width: root.width
        placeholderText: root.emptyHiddenPlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !hiddenDropAreaButton.visible
        empty: root.showcaseModel.hiddenCount === 0 && !root.flickable2Folded // TO BE REMOVE: #13498
        additionalFooterComponent: root.additionalFooterComponent
        spacing: Style.current.halfPadding

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("Hidden")
            folded: root.flickable2Folded
            rightAdditionalComponent: VisibilityDropAreaButton {
                visible: root.flickable2Folded && (d.isAnyShowcaseDragActive || parent.containsDrag || containsDrag)
                width: d.additionalHeaderComponentWidth
                height: d.additionalHeaderComponentHeight
                rightInset: 1
                text: qsTr("Hide")
                dropAreaKeys: d.dragShowcaseItemKey

                onDropped: {
                    root.showcaseModel.setVisibilityByIndex(drop.source.visualIndex, visibility)
                    root.showcaseEntryChanged()
                }
            }

            onToggleFolding: root.flip2Folding()
        }

        delegate: DropArea {
            id: hiddenDelegateRoot

            property int visualIndex: index

            visible: root.filterFunc(model)
            width: ListView.view.width
            height: visible && hiddenDraggableDelegateLoader.item ? hiddenDraggableDelegateLoader.item.height : 0

            keys: d.dragShowcaseItemKey

            onEntered: function(drag) {
                drag.accept()
            }

            onDropped: function(drop) {
                root.showcaseModel.setVisibilityByIndex(drop.source.visualIndex, Constants.ShowcaseVisibility.NoOne)
                root.showcaseEntryChanged()
            }

            // Hidden delegate item container:
            Loader {
                id: hiddenDraggableDelegateLoader

                property var modelData: model
                property var dragParentData: root
                property int visualIndexData: hiddenDelegateRoot.visualIndex

                width: parent.width
                sourceComponent: root.hiddenDraggableDelegateComponent
            }

            // Delegate shadow background when dragging:
            ShadowDelegate {
                id: hiddenShadow

                visible: hiddenDraggableDelegateLoader.item && hiddenDraggableDelegateLoader.item.dragActive
                onVisibleChanged: d.isAnyHiddenDragActive = visible
            }

            Binding {
                when: hiddenDropAreaButton.visible
                target: hiddenDraggableDelegateLoader.item
                property: "blurState"
                value: true
                restoreMode: Binding.RestoreBindingOrValue
            }
        }

        // Overlaid hidden listview content drop area:
        DropArea {
            anchors.top: parent.top
            width: parent.width
            height: parent.contentHeight
            keys: d.dragShowcaseItemKey

            // Shown at the top of the listview
            VisibilityDropAreaButton {
                id: hiddenDropAreaButton

                anchors.top: parent.top
                anchors.topMargin: hiddenListView.headerItem.height + Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter

                visible: d.isAnyShowcaseDragActive || parent.containsDrag || hiddenDropAreaButton.containsDrag
                width: parent.width - Style.current.padding
                height: ProfileUtils.defaultDelegateHeight - Style.current.padding
                text: qsTr("Hide")
                dropAreaKeys: d.dragShowcaseItemKey

                onDropped: {
                    root.showcaseModel.setVisibilityByIndex(drop.source.visualIndex, visibility)
                    root.showcaseEntryChanged()
                    root.updateBaseModelFilters()
                }
            }
        }
    }

    component VisibilityDropAreaButton: AbstractButton {
        id: visibilityDropAreaButton

        readonly property alias containsDrag: dropArea.containsDrag

        property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        property var dropAreaKeys

        signal dropped(var drop, int visibility)

        padding: Style.current.halfPadding
        spacing: padding/2

        icon.color: Theme.palette.primaryColor1

        background: ShapeRectangle {
            path.strokeColor: dropArea.containsDrag ? Theme.palette.primaryColor2 : Theme.palette.directColor7
            path.fillColor: dropArea.containsDrag ? Theme.palette.primaryColor3 : Theme.palette.baseColor4

            DropArea {
                id: dropArea

                anchors.fill: parent
                keys: visibilityDropAreaButton.dropAreaKeys

                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    visibilityDropAreaButton.dropped(drop, visibilityDropAreaButton.showcaseVisibility)
                }
            }
        }

        contentItem: Item {
            RowLayout {
                width: Math.min(parent.width, implicitWidth)
                anchors.centerIn: parent
                spacing: visibilityDropAreaButton.spacing

                StatusIcon {
                    width: 20
                    height: width
                    icon: ProfileUtils.visibilityIcon(visibilityDropAreaButton.showcaseVisibility)
                    color: visibilityDropAreaButton.icon.color
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: Style.current.additionalTextSize
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    color: visibilityDropAreaButton.icon.color
                    text: visibilityDropAreaButton.text
                }
            }
        }
    }

    component VisibilityDropAreaButtonsRow: Item {
        id: visibilityDropAreaRow

        readonly property bool everyoneContainsDrag: dropAreaEveryone.containsDrag
        readonly property bool contactsContainsDrag: dropAreaContacts.containsDrag
        readonly property bool verifiedContainsDrag: dropAreaVerified.containsDrag
        property int margins: Style.current.halfPadding

        function dropped(drop, visibility) {
            var showcaseObj = drop.source.showcaseObj

            // need to set total balance for an asset
            if (drop.source.totalValue !== undefined) {
                showcaseObj.enabledNetworkBalance = drop.source.totalValue
            }

            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = visibility
            root.showcaseModel.upsertItemJson(JSON.stringify(tmpObj))
            root.showcaseEntryChanged()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: visibilityDropAreaRow.margins
            spacing: Style.current.halfPadding

            VisibilityDropAreaButton {
                id: dropAreaEveryone
                Layout.fillWidth: true
                Layout.fillHeight: true
                showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                text: qsTr("Everyone")
                dropAreaKeys: d.dragHiddenItemKey

                onDropped: visibilityDropAreaRow.dropped(drop, visibility)
            }

            VisibilityDropAreaButton {
                id: dropAreaContacts
                Layout.fillWidth: true
                Layout.fillHeight: true
                showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                text: qsTr("Contacts")
                dropAreaKeys: d.dragHiddenItemKey

                onDropped: visibilityDropAreaRow.dropped(drop, visibility)
            }

            VisibilityDropAreaButton {
                id: dropAreaVerified
                Layout.fillWidth: true
                Layout.fillHeight: true
                showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
                text: qsTr("Verified")
                dropAreaKeys: d.dragHiddenItemKey

                onDropped: visibilityDropAreaRow.dropped(drop, visibility)
            }
        }
    }

    component ShadowDelegate: Rectangle {
        width: parent.width
        height: ProfileUtils.defaultDelegateHeight
        anchors.centerIn: parent
        color: Theme.palette.baseColor5
        radius: Style.current.radius
    }
}

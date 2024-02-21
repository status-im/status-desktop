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

        readonly property int defaultDelegateHeight: 60
        readonly property int contentSpacing: 12
        readonly property int strokeMargin: 2
        readonly property int shapeRectangleHeight: 48
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
        placeholderHeight: d.shapeRectangleHeight

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("In showcase")
            folded: root.flickable1Folded

            onToggleFolding: root.flip1Folding()
        }

        delegate: DropArea {
            id: showcaseDelegateRoot

            property int visualIndex: index

            width: ListView.view.width
            height: visible && showcaseDraggableDelegateLoader.item ? showcaseDraggableDelegateLoader.item.height : 0

            keys: ["x-status-draggable-showcase-item"]
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
                width: parent.width
                sourceComponent: root.showcaseDraggableDelegateComponent

                property var modelData: model
                property var dragParentData: root
                property int visualIndexData: index
            }
        }

        // TO BE REDEFINED (task #13509): Overlaid at the bottom of the listview
        DropArea {
            id: targetDropArea
            width: parent.width
            height: inShowcaseListView.count === 0 ? d.shapeRectangleHeight : d.defaultDelegateHeight
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.showcaseModel.count ? Style.current.halfPadding : 0
            keys: ["x-status-draggable-showcase-item-hidden"]

            Rectangle {
                id: showcaseCombinedDropArea
                width: parent.width
                height: parent.height + d.strokeMargin
                anchors.centerIn: parent
                color: Theme.palette.baseColor5
                radius: Style.current.radius
                visible: parent.containsDrag || dropAreaEveryone.containsDrag || dropAreaContacts.containsDrag || dropAreaVerified.containsDrag

                RowLayout {
                    width: parent.width - spacing*2
                    anchors.centerIn: parent
                    spacing: d.contentSpacing
                    VisibilityDropArea {
                        id: dropAreaEveryone
                        Layout.fillWidth: true
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                        text: qsTr("Everyone")
                    }
                    VisibilityDropArea {
                        id: dropAreaContacts
                        Layout.fillWidth: true
                        showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                        text: qsTr("Contacts")
                    }
                    VisibilityDropArea {
                        id: dropAreaVerified
                        Layout.fillWidth: true
                        showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
                        text: qsTr("Verified")
                    }
                }
            }
        }
    }

    flickable2: EmptyShapeRectangleFooterListView {
        id: hiddenListView

        model: root.baseModel
        width: root.width
        placeholderText: root.emptyHiddenPlaceholderText
        placeholderHeight: d.shapeRectangleHeight
        empty: root.showcaseModel.hiddenCount === 0 && !root.flickable2Folded // TO BE REMOVE: #13498
        additionalFooterComponent: root.additionalFooterComponent

        header: FoldableHeader {
            width: ListView.view.width
            title: qsTr("Hidden")
            folded: root.flickable2Folded

            onToggleFolding: root.flip2Folding()
        }

        delegate: DropArea {
            id: hiddenDelegateRoot

            property int visualIndex: index

            visible: root.filterFunc(model)
            width: ListView.view.width
            height: visible && hiddenDraggableDelegateLoader.item ? hiddenDraggableDelegateLoader.item.height : 0

            keys: ["x-status-draggable-showcase-item"]

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
                width: parent.width
                sourceComponent: root.hiddenDraggableDelegateComponent

                property var modelData: model
                property var dragParentData: root
                property int visualIndexData: hiddenDelegateRoot.visualIndex
            }

            // Delegate shadow background when dragging:
            Rectangle {
                width: parent.width
                height: d.defaultDelegateHeight
                anchors.centerIn: parent
                color: Theme.palette.baseColor5
                radius: Style.current.radius
                visible: hiddenDraggableDelegateLoader.item && hiddenDraggableDelegateLoader.item.dragActive
            }
        }

        // TO BE REDEFINED (task #13509): Overlaid at the top of the listview
        DropArea {
            id: hiddenTargetDropArea
            width: root.width
            height: hiddenListView.empty ? d.shapeRectangleHeight : d.defaultDelegateHeight
            anchors.top: hiddenListView.top
            anchors.topMargin: hiddenListView.empty ? hiddenListView.headerItem.height : hiddenListView.headerItem.height + Style.current.halfPadding
            keys: ["x-status-draggable-showcase-item"]

            ShapeRectangle {
                width: parent.width
                height: parent.height + d.strokeMargin
                anchors.centerIn: parent
                visible: parent.containsDrag
                path.fillColor: Theme.palette.baseColor5
                path.strokeColor: "transparent"
                text: root.emptyHiddenPlaceholderText
            }

            onEntered: function(drag) {
                drag.accept()
            }

            onDropped: function(drop) {
                root.showcaseModel.setVisibilityByIndex(drop.source.visualIndex, Constants.ShowcaseVisibility.NoOne)
                root.showcaseEntryChanged()
                root.updateBaseModelFilters()
            }
        }
    }

    // TO BE REDEFINED (task #13509)
    component VisibilityDropArea: AbstractButton {
        id: visibilityDropAreaLocal

        property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        readonly property alias containsDrag: dropArea.containsDrag

        padding: Style.current.halfPadding
        spacing: padding/2

        icon.color: Theme.palette.primaryColor1

        background: ShapeRectangle {
            path.strokeColor: dropArea.containsDrag ? "transparent" : Theme.palette.directColor7
            path.fillColor: dropArea.containsDrag ? Theme.palette.white : "transparent"

            DropArea {
                id: dropArea
                anchors.fill: parent
                keys: ["x-status-draggable-showcase-item-hidden"]
                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    var showcaseObj = drop.source.showcaseObj

                    // need to set total balance for an asset
                    if (drop.source.totalValue !== undefined) {
                        showcaseObj.enabledNetworkBalance = drop.source.totalValue
                    }

                    var tmpObj = Object()
                    root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
                    tmpObj.showcaseVisibility = visibilityDropAreaLocal.showcaseVisibility
                    root.showcaseModel.upsertItemJson(JSON.stringify(tmpObj))
                    root.showcaseEntryChanged()
                }
            }
        }

        contentItem: Item {
            RowLayout {
                width: Math.min(parent.width, implicitWidth)
                anchors.centerIn: parent
                spacing: visibilityDropAreaLocal.spacing

                StatusIcon {
                    width: 20
                    height: width
                    icon: ProfileUtils.visibilityIcon(visibilityDropAreaLocal.showcaseVisibility)
                    color: visibilityDropAreaLocal.icon.color
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    color: visibilityDropAreaLocal.icon.color
                    text: visibilityDropAreaLocal.text
                }
            }
        }
    }
}

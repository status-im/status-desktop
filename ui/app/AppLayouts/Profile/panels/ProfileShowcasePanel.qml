import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import utils 1.0

import AppLayouts.Profile.controls 1.0

DoubleFlickableWithFolding {
    id: root

    property Component delegate: ProfileShowcasePanelDelegate {}

    // Expected roles: 
    // - visibility: int
    property var inShowcaseModel
    property var hiddenModel

    property Component additionalFooterComponent

    // Placeholder text to be shown when the list is empty
    property string emptyInShowcasePlaceholderText
    property string emptyHiddenPlaceholderText

    // Signal to requst position change of the visible items
    signal changePositionRequested(int from, int to)
    // Signal to request visibility change of the items
    signal setVisibilityRequested(var key, int toVisibility)

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

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

    flickable1: EmptyShapeRectangleFooterListView {
        id: inShowcaseListView

        width: root.width
        placeholderText: root.emptyInShowcasePlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !dropAreaRow.visible
        spacing: Style.current.halfPadding
        delegate: delegateWrapper
        model: root.inShowcaseModel

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

        width: root.width
        placeholderText: root.emptyHiddenPlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !hiddenDropAreaButton.visible
        additionalFooterComponent: root.additionalFooterComponent
        spacing: Style.current.halfPadding
        delegate: delegateWrapper
        model: root.hiddenModel

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

                onDropped: root.setVisibilityRequested(drop.source.key, visibility)
            }

            onToggleFolding: root.flip2Folding()
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

                onDropped: root.setVisibilityRequested(drop.source.key, visibility)
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
            root.setVisibilityRequested(drop.source.key,  visibility)
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
    
    Component {
        id: delegateWrapper
         DropArea {
            id: showcaseDelegateRoot

            required property var model
            required property int index
            readonly property int visualIndex: index
            readonly property bool isHiddenShowcaseItem: !model.visibility || model.visibility === Constants.ShowcaseVisibility.NoOne

            function handleEntered(drag) {
                if (!showcaseDelegateRoot.isHiddenShowcaseItem) {
                    var from = drag.source.visualIndex
                    var to = visualIndex
                    if (to === from)
                        return
                    root.changePositionRequested(drag.source.visualIndex, to)
                }
                drag.accept()
            }
            function handleDropped(drop) {
                if (showcaseDelegateRoot.isHiddenShowcaseItem) {
                    root.setVisibilityRequested(drop.source.key, Constants.ShowcaseVisibility.NoOne)
                }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: true }
                NumberAnimation { target: showcaseDelegateRoot; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
                PropertyAction { target: showcaseDelegateRoot; property: "ListView.delayRemove"; value: false }
            }

            width: ListView.view.width
            height: showcaseDraggableDelegateLoader.item ? showcaseDraggableDelegateLoader.item.height : 0
            keys: d.dragShowcaseItemKey

            onEntered: handleEntered(drag)
            onDropped: handleDropped(drop)

            // In showcase delegate item container:
            Loader {
                id: showcaseDraggableDelegateLoader

                property var modelData: showcaseDelegateRoot.model
                property var dragParentData: root
                property int visualIndexData: showcaseDelegateRoot.index
                property var dragKeysData: showcaseDelegateRoot.isHiddenShowcaseItem ?
                                           d.dragHiddenItemKey : d.dragShowcaseItemKey

                width: parent.width
                sourceComponent: root.delegate
                onItemChanged: {
                    if (item) {
                        item.showcaseVisibilityRequested.connect((toVisibility) => root.setVisibilityRequested(showcaseDelegateRoot.model.key, toVisibility))
                    }
                }
            }

            Binding {
                 when: showcaseDelegateRoot.isHiddenShowcaseItem ? d.isAnyShowcaseDragActive : d.isAnyHiddenDragActive
                 target: showcaseDraggableDelegateLoader.item
                 property: "blurState"
                 value: true
                 restoreMode: Binding.RestoreBindingOrValue
             }

             Binding {
                when: showcaseShadow.visible
                target: d
                property: showcaseDelegateRoot.isHiddenShowcaseItem ? "isAnyHiddenDragActive" : "isAnyShowcaseDragActive"
                value: true
                restoreMode: Binding.RestoreBindingOrValue
             }

            // Delegate shadow background when dragging:
            ShadowDelegate {
                id: showcaseShadow

                visible: showcaseDraggableDelegateLoader.item && showcaseDraggableDelegateLoader.item.dragActive
            }

            // Delegate shadow background when dragging:
            Rectangle {
                width: parent.width
                height: d.defaultDelegateHeight
                anchors.centerIn: parent
                color: Theme.palette.baseColor5
                radius: Style.current.radius
                visible: showcaseShadow.visible
            }
        }
    }
}

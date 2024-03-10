import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import shared.controls 1.0
import utils 1.0

import AppLayouts.Profile.controls 1.0

import SortFilterProxyModel 0.2

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
    property string emptySearchPlaceholderText

    property int showcaseLimit: 100

    // Searcher related properties:
    property string searchPlaceholderText
    property string searcherText: ""

    // Signal to request position change of the visible items
    signal changePositionRequested(int from, int to)

    // Signal to request visibility change of the items
    signal setVisibilityRequested(var key, int toVisibility)

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }

    QtObject {
        id: d

        readonly property bool limitReached: root.showcaseLimit === inShowcaseCounterTracker.count
        readonly property bool searchActive: root.searcherText !== ""

        readonly property var dragHiddenItemKey: ["x-status-draggable-showcase-item-hidden"]
        readonly property var dragShowcaseItemKey: ["x-status-draggable-showcase-item"]

        property bool isAnyShowcaseDragActive: false
        property bool isAnyHiddenDragActive: false

        property int additionalHeaderComponentWidth: 350 // by design
        property int additionalHeaderComponentHeight: 40 // by design

        property bool startAnimation: false

        property var dragItem: null

        signal setVisibilityInternalRequested(var key, int toVisibility)
        onSetVisibilityInternalRequested: {
            if(toVisibility !== Constants.ShowcaseVisibility.NoOne) {
                startAnimation = !startAnimation
            }
            root.setVisibilityRequested(key, toVisibility)
        }
    }

    ModelChangeTracker {
        id: inShowcaseCounterTracker

        property int count: {
            revision
            return model.rowCount()
        }

        model: root.inShowcaseModel
    }

    clip: true

    flickable1: EmptyShapeRectangleFooterListView {
        id: inShowcaseListView

        model: root.inShowcaseModel
        width: root.width
        placeholderText: d.searchActive ? root.emptySearchPlaceholderText : root.emptyInShowcasePlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !dropAreaRow.visible
        spacing: Style.current.halfPadding
        delegate: delegateWrapper
        header: ColumnLayout {
            width: ListView.view.width
            spacing: 0

            SearchBox {
                id: searcher

                Layout.fillWidth: true

                placeholderText: root.searchPlaceholderText
                validators: [
                    StatusValidator {
                        property bool isEmoji: false

                        name: "check-for-no-emojis"
                        validate: (value) => {
                                      if (!value) {
                                          return true
                                      }

                                      isEmoji = Constants.regularExpressions.emoji.test(value)
                                      if (isEmoji){
                                          return false
                                      }

                                      return Constants.regularExpressions.alphanumericalExpanded1.test(value)
                                  }
                        errorMessage: isEmoji ?
                                          qsTr("Your search is too cool (use A-Z and 0-9, hyphens and underscores only)")
                                        : qsTr("Your search contains invalid characters (use A-Z and 0-9, hyphens and underscores only)")
                    }
                ]

                Binding {
                    target: root
                    property: "searcherText"
                    value: searcher.text
                    restoreMode: Binding.RestoreBindingOrValue
                }
            }

            FoldableHeader {
                readonly property bool isDropAreaVisible: root.flickable1Folded && d.isAnyHiddenDragActive

                Layout.fillWidth: true

                title: qsTr("In showcase")
                folded: root.flickable1Folded
                rightAdditionalComponent: isDropAreaVisible && d.limitReached ? limitReachedHeaderButton :
                                                                                isDropAreaVisible ? dropHeaderAreaComponent : counterComponent

                Component {
                    id: counterComponent
                    StatusBaseText {
                        id: counterText

                        width: d.additionalHeaderComponentWidth
                        height: d.additionalHeaderComponentHeight
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        text: "%1 / %2".arg(inShowcaseCounterTracker.count).arg(root.showcaseLimit)
                        font.pixelSize: Style.current.tertiaryTextFontSize
                        color: Theme.palette.baseColor1

                        ColorAnimation {
                            id: animateColor
                            target: counterText
                            properties: "color"
                            from: Theme.palette.successColor1
                            to: Theme.palette.baseColor1
                            duration: 2000
                        }

                        Connections {
                            target: d
                            function onStartAnimationChanged() {
                                animateColor.start()
                            }
                        }
                    }
                }

                Component {
                    id: dropHeaderAreaComponent
                    VisibilityDropAreaButtonsRow {
                        margins: 0
                        width: d.additionalHeaderComponentWidth
                        height: d.additionalHeaderComponentHeight
                    }
                }

                Component {
                    id: limitReachedHeaderButton
                    VisibilityDropAreaButton {
                        width: d.additionalHeaderComponentWidth
                        height: d.additionalHeaderComponentHeight
                        rightInset: 1
                        text: qsTr("Showcase limit of %1 reached").arg(root.showcaseLimit)
                        enabled: false
                        textColor: Theme.palette.baseColor1
                        iconVisible: false
                    }
                }

                onToggleFolding: root.flip1Folding()
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
                visible: !d.limitReached &&
                         (d.isAnyHiddenDragActive ||
                          parent.containsDrag ||
                          everyoneContainsDrag ||
                          contactsContainsDrag ||
                          verifiedContainsDrag)
            }
        }

        // Overlaid showcase listview content when limit reached:
        VisibilityDropAreaButton {
            id: limitReachedButton

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.halfPadding
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Style.current.padding
            height: ProfileUtils.defaultDelegateHeight - Style.current.padding
            visible: d.isAnyHiddenDragActive && d.limitReached
            enabled: false
            text: qsTr("Showcase limit of %1 reached").arg(root.showcaseLimit)
            textColor: Theme.palette.baseColor1
            iconVisible: false
        }
    }

    flickable2: EmptyShapeRectangleFooterListView {
        id: hiddenListView

        model: root.hiddenModel
        width: root.width
        placeholderText: d.searchActive ? root.emptySearchPlaceholderText : root.emptyHiddenPlaceholderText
        footerHeight: ProfileUtils.defaultDelegateHeight
        footerContentVisible: !hiddenDropAreaButton.visible
        additionalFooterComponent: root.additionalFooterComponent
        spacing: Style.current.halfPadding
        delegate: delegateWrapper

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
                
            }
        }
    }

    component VisibilityDropAreaButton: AbstractButton {
        id: visibilityDropAreaButton

        readonly property alias containsDrag: dropArea.containsDrag

        property bool iconVisible: true
        property string textColor: icon.color
        property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        property var dropAreaKeys: []

        padding: Style.current.halfPadding
        spacing: padding/2

        icon.color: Theme.palette.primaryColor1

        visible: d.dragItem && d.dragItem.showcaseMaxVisibility >= showcaseVisibility

        background: ShapeRectangle {
            path.strokeColor: dropArea.containsDrag ? Theme.palette.primaryColor2 : Theme.palette.directColor7
            path.fillColor: dropArea.containsDrag ? Theme.palette.primaryColor3 : Theme.palette.getColor(Theme.palette.baseColor4, 0.7)

            DropArea {
                id: dropArea

                anchors.fill: parent
                keys: visibilityDropAreaButton.dropAreaKeys

                onEntered: function(drag) {
                    drag.accept()
                }

                onDropped: function(drop) {
                    d.setVisibilityInternalRequested(drop.source.key, visibilityDropAreaButton.showcaseVisibility)
                }
            }
        }

        contentItem: Item {
            RowLayout {
                width: Math.min(parent.width, implicitWidth)
                anchors.centerIn: parent
                spacing: visibilityDropAreaButton.spacing

                StatusIcon {
                    visible: visibilityDropAreaButton.iconVisible
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
                    color: visibilityDropAreaButton.textColor
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
            }

            VisibilityDropAreaButton {
                id: dropAreaContacts
                Layout.fillWidth: true
                Layout.fillHeight: true
                showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                text: qsTr("Contacts")
                dropAreaKeys: d.dragHiddenItemKey
            }

            VisibilityDropAreaButton {
                id: dropAreaVerified
                Layout.fillWidth: true
                Layout.fillHeight: true
                showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
                text: qsTr("Verified")
                dropAreaKeys: d.dragHiddenItemKey
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
            readonly property bool isHiddenShowcaseItem: !model.showcaseVisibility || model.showcaseVisibility === Constants.ShowcaseVisibility.NoOne

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
                    d.setVisibilityInternalRequested(drop.source.key, Constants.ShowcaseVisibility.NoOne)
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
                        item.showcaseVisibilityRequested.connect((toVisibility) => d.setVisibilityInternalRequested(showcaseDelegateRoot.model.showcaseKey, toVisibility))
                    }
                }
            }

            Binding {
                when: showcaseDelegateRoot.isHiddenShowcaseItem ? d.isAnyShowcaseDragActive : (d.isAnyHiddenDragActive ||
                                                                                               (d.isAnyHiddenDragActive && d.limitReached))
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

            Binding {
                when: showcaseDelegateRoot.isHiddenShowcaseItem && d.limitReached
                target: showcaseDraggableDelegateLoader.item
                property: "contextMenuEnabled"
                value: false
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding {
                when: showcaseDelegateRoot.isHiddenShowcaseItem  && d.limitReached
                target: showcaseDraggableDelegateLoader.item
                property: "tooltipTextWhenContextMenuDisabled"
                value: qsTr("Showcase limit of %1 reached. <br>Remove item from showcase to add more.").arg(root.showcaseLimit)
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding {
                when: showcaseDraggableDelegateLoader.item && showcaseDraggableDelegateLoader.item.dragActive
                target: d
                property: "dragItem"
                value: showcaseDraggableDelegateLoader.item
                restoreMode: Binding.RestoreBindingOrValue
            }

            // Delegate shadow background when dragging:
            ShadowDelegate {
                id: showcaseShadow

                visible: showcaseDraggableDelegateLoader.item && showcaseDraggableDelegateLoader.item.dragActive
            }
        }
    }
}

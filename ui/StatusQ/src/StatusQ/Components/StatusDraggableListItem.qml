import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusDraggableListItem
   \inherits QtQuickControls::ItemDelegate
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a list item with the ability to be dragged and dropped to reorder within a list view. Inherits from \c QtQuickControls::ItemDelegate.

   The \c StatusDraggableListItem is a list item with an icon, title and a subtitle on the left side, and optional actions on the right.

   It displays a drag handle on its left side

   Example of how to use it:

   \qml
        StatusListView {
            id: linksView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.socialLinksModel

            displaced: Transition {
                NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
            }

            delegate: DropArea {
                id: delegateRoot

                property int visualIndex: index

                width: ListView.view.width
                height: draggableDelegate.height

                keys: ["x-status-draggable-list-item-internal"]

                onEntered: function(drag) {
                    const from = drag.source.visualIndex
                    const to = draggableDelegate.visualIndex
                    if (to === from)
                        return
                    root.profileStore.moveLink(from, to, 1)
                    drag.accept()
                }

                onDropped: function(drop) {
                    root.profileStore.saveSocialLinks(true)
                }

                StatusDraggableListItem {
                    id: draggableDelegate

                    readonly property string asideText: ProfileUtils.stripSocialLinkPrefix(model.url, model.linkType)

                    visible: !!asideText
                    width: parent.width
                    height: visible ? implicitHeight : 0

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }

                    dragParent: linksView
                    visualIndex: delegateRoot.visualIndex
                    draggable: linksView.count > 1
                    title: ProfileUtils.linkTypeToText(model.linkType) || model.text
                    icon.name: model.icon
                    icon.color: ProfileUtils.linkTypeColor(model.linkType)
                    actions: [
                        StatusLinkText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.primaryTextFontSize
                            font.weight: Font.Normal
                            text: draggableDelegate.asideText
                            onClicked: Global.openLink(model.url)
                        },
                        StatusFlatRoundButton {
                            icon.name: "edit_pencil"
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            icon.width: 16
                            icon.height: 16
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Edit link")
                            onClicked: Global.openPopup(modifySocialLinkModal,
                                                        {linkType: model.linkType, icon: model.icon, uuid: model.uuid,
                                                            linkText: model.text, linkUrl: draggableDelegate.asideText})
                        }
                    ]
                }
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
ItemDelegate {
    id: root

    /*!
       \qmlproperty string StatusDraggableListItem::title
       This property holds the primary text (title)
    */
    property string title: text
    /*!
       \qmlproperty string StatusDraggableListItem::secondaryTitle
       This property holds the secondary text (title), displayed below primary
    */
    property string secondaryTitle

    /*!
       \qmlproperty list<Item> StatusDraggableListItem::actions
       This property holds the optional list of actions, displayed on the right side.
       The actions are reparented into a RowLayout.
    */
    property list<Item> actions
    onActionsChanged: {
        for (let idx in actions) {
            let action = actions[idx]
            action.parent = actionsRow
        }
    }

    /*!
       \qmlproperty Item StatusDraggableListItem::dragParent
       This property holds the drag parent (the Item that this Item gets reparented to when being dragged)
    */
    property Item dragParent
    /*!
       \qmlproperty int StatusDraggableListItem::visualIndex
       This property holds the persistent visual index of this item's parent (usually a DropArea)
    */
    property int visualIndex
    /*!
       \qmlproperty bool StatusDraggableListItem::draggable
       This property holds whether this item can be dragged (and whether the drag handle is displayed)
    */
    property bool draggable

    Drag.dragType: Drag.Automatic
    Drag.hotSpot.x: root.width/2
    Drag.hotSpot.y: root.height/2
    Drag.keys: ["x-status-draggable-list-item-internal"]

    /*!
       \qmlproperty readonly bool StatusDraggableListItem::dragActive
       This property holds whether a drag is currently in progress
    */
    readonly property bool dragActive: draggable && dragHandler.drag.active
    onDragActiveChanged: {
        if (dragActive)
            Drag.start()
        else
            Drag.drop()
    }

    states: [
        State {
            when: root.dragActive
            ParentChange {
                target: root
                parent: root.dragParent
            }

            AnchorChanges {
                target: root
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: undefined
            }
        }
    ]

    background: Rectangle {
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 8

        MouseArea {
            id: dragHandler
            anchors.fill: parent
            drag.target: root
            drag.axis: Drag.YAxis
            preventStealing: true // otherwise DND is broken inside a Flickable/ScrollView
            hoverEnabled: true
            cursorShape: root.dragActive ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        }
    }

    // inset to simulate spacing
    topInset: 6
    bottomInset: 6

    horizontalPadding: 12
    verticalPadding: 16
    spacing: 8

    icon.width: 20
    icon.height: 20

    contentItem: RowLayout {
        spacing: root.spacing

        StatusIcon {
            icon: "justify"
            visible: root.draggable
        }

        StatusIcon {
            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            Layout.leftMargin: root.spacing/2
            icon: root.icon.name
            color: root.icon.color
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: root.title
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // TODO secondaryTitle

        RowLayout {
            id: actionsRow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 12
        }
    }
}

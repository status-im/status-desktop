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

   The \c StatusDraggableListItem is a list item with a (smartident)icon, title and a subtitle on the left side, and optional actions on the right.

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
       \qmlproperty string StatusDraggableListItem::secondaryTitleIcon
       This property holds the secondary title icon, displayed on the right of the secondary title
    */
    property string secondaryTitleIcon: ""

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
    /*!
       \qmlproperty bool StatusDraggableListItem::customizable
       This property holds whether this item can be customized
    */
    property bool customizable: false
    /*!
        \qmlsignal
        This signal is emitted when the StatusDraggableListItem is clicked.
    */
    signal clicked(var mouse)

    /*!
       \qmlproperty int StatusDraggableListItem::dragAxis
       This property holds whether this item can be dragged along the x-axis (Drag.XAxis), y-axis (Drag.YAxis),
       or both (Drag.XAndYAxis). Defaults to Drag.YAxis
    */
    property int dragAxis: Drag.YAxis

    /*!
       \qmlproperty bool StatusDraggableListItem::hasIcon
       This property holds whether this item wants to display an icon (using a StatusIcon); use `icon.name`
       Defaults to false
    */
    property bool hasIcon: false
    /*!
       \qmlproperty bool StatusDraggableListItem::hasImage
       This property holds whether this item wants to display an image (using a StatusRoundedImage); use `icon.source`
       Specifying `icon.name` adds a fallback to a letter identicon (using StatusLetterIdenticon).
       Defaults to false
    */
    property bool hasImage: false
    /*!
       \qmlproperty bool StatusDraggableListItem::hasEmoji
       This property holds whether this item wants to display an emoji (using a StatusLetterIdenticon); use `icon.name`
       Defaults to false
    */
    property bool hasEmoji: false

    /*!
       \qmlproperty int StatusDraggableListItem::bgRadius
       This property holds the background corner radius in pixels (if the background is visible)
       Defaults to "rounded", half of the icon width or height
    */
    property int bgRadius: icon.height/2
    /*!
       \qmlproperty color StatusDraggableListItem::bgColor
       This property holds background color, if any
       Defaults to "transparent" (ie no background)
    */
    property color bgColor: "transparent"

    Drag.dragType: Drag.Automatic
    Drag.hotSpot.x: dragHandler.mouseX
    Drag.hotSpot.y: dragHandler.mouseY
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
        color: root.dragActive && !root.customizable ? Theme.palette.indirectColor2 : "transparent"
        border.width: root.customizable ? 0 : 1
        border.color: Theme.palette.baseColor2
        radius: customizable ? 0 : 8

        MouseArea {
            id: dragHandler
            anchors.fill: parent
            drag.target: root.draggable ? root : null
            drag.axis: root.dragAxis
            preventStealing: true // otherwise DND is broken inside a Flickable/ScrollView
            hoverEnabled: true
            cursorShape: root.dragActive ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                root.clicked(mouse);
            }
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
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            icon: "justify"
            visible: root.draggable && !root.customizable
        }

        Loader {
            Layout.leftMargin: root.spacing/2
            asynchronous: true
            active: !!root.icon.name || !!root.icon.source
            visible: active
            sourceComponent: root.hasIcon ? iconComponent : root.hasImage ? imageComponent : letterIdenticonComponent
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.secondaryTitle ? 4 : 0

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                visible: text
                elide: Text.ElideRight
                maximumLineCount: 1
                font.weight: root.highlighted ? Font.Medium : Font.Normal
            }

            Row {
                Layout.fillWidth: true
                visible: !!root.secondaryTitle
                spacing: 8

                StatusBaseText {
                    text: root.secondaryTitle
                    color: Theme.palette.baseColor1
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Loader {
                    asynchronous: true
                    active: !!root.secondaryTitleIcon
                    visible: active
                    sourceComponent: secondaryTitleIconComponent
                }
            }
        }

        RowLayout {
            id: actionsRow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 12
        }
    }

    Component {
        id: iconComponent
        StatusIcon {
            width: root.icon.width
            height: root.icon.height
            icon: root.icon.name
            color: root.icon.color
            source: root.icon.source
        }
    }

    Component {
        id: secondaryTitleIconComponent
        StatusIcon {
            width: 16
            height: 16
            icon: root.secondaryTitleIcon
            color: Theme.palette.baseColor1
        }
    }

    Component {
        id: imageComponent
        StatusRoundedImage {
            radius: root.bgRadius
            color: root.bgColor
            width: root.icon.width
            height: root.icon.height
            image.source: root.icon.source
            image.sourceSize: Qt.size(width, height)
            image.smooth: false
            image.mipmap: true
            showLoadingIndicator: true
            image.fillMode: Image.PreserveAspectCrop
        }
    }

    Component {
        id: letterIdenticonComponent
        StatusLetterIdenticon {
            width: root.icon.width
            height: root.icon.height
            emoji: root.hasEmoji ? root.icon.name : ""
            name: !root.hasEmoji ? root.icon.name : ""
            color: root.icon.color
        }
    }
}

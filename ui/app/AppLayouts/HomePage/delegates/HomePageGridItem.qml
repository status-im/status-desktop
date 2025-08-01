import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Popups

import utils

import AppLayouts.HomePage

AbstractButton {
    id: root

    /*required */property int sectionType // cf Constants.appSection.*

    property string itemId
    property string title
    property string subtitle: Utils.translatedSectionName(sectionType)
    property color color
    property url banner
    property bool hasNotification
    property int notificationsCount
    property alias bottomRowComponent: bottomRowLoader.sourceComponent
    property bool bottomRowComponentFillsWidth: false
    property alias iconLoaderComponent: iconLoader.sourceComponent

    property bool pinned

    property var extraMenuActions: []

    implicitWidth: 160
    implicitHeight: 160

    padding: Theme.defaultSmallPadding

    icon.width: 48
    icon.height: 48

    signal pinRequested

    layer.enabled: true
    layer.effect: Glow {
        samples: 33
        spread: 0.1
        color: root.hovered ? Theme.palette.backdropColor : Theme.palette.dropShadow
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
    }

    background: Item {
        StatusRoundedImage {
            id: mainBgImage
            anchors.top: parent.top
            width: parent.width
            height: 40 + radius*2 // draw under the rect below
            color: root.color
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
            radius: Theme.defaultPadding
            image.source: root.banner
            image.verticalAlignment: Image.AlignTop
            image.fillMode: Image.Tile

            opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
            Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }
        }

        // rect overlapping the above image
        Rectangle {
            id: mainBgRect
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.bottom: parent.bottom
            width: parent.width

            color: hovered ? Qt.lighter(Theme.palette.baseColor4, 1.5) : Theme.palette.baseColor4
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }

            radius: mainBgImage.radius
        }
    }

    onPressAndHold: contextMenuComponent.createObject(root).popup(root.pressX, root.pressY)

    contentItem: Item {
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.RightButton
            cursorShape: containsMouse ? Qt.PointingHandCursor : undefined
            onClicked: contextMenuComponent.createObject(root).popup()
        }

        // contents
        ColumnLayout {
            anchors.fill: parent

            // icon/image
            Rectangle {
                Layout.preferredWidth: root.icon.width
                Layout.preferredHeight: root.icon.height

                color: mainBgRect.color
                radius: width/2

                Loader {
                    id: iconLoader
                    anchors.fill: parent
                    anchors.margins: 2
                }
            }

            // title
            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.weight: Font.DemiBold
                elide: Text.ElideRight

                HoverHandler {
                    id: titleTextHHandler
                    enabled: parent.truncated
                }
                StatusToolTip {
                    visible: titleTextHHandler.hovered
                    offset: -(x + width/2 - root.width/2)
                    text: root.title
                }
            }

            // subtitle
            StatusBaseText {
                Layout.fillWidth: true
                text: root.subtitle
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                color: Theme.palette.baseColor1
                elide: Text.ElideRight
            }

            // extra bottom contents
            RowLayout {
                Layout.alignment: Qt.AlignBottom
                Layout.minimumHeight: Theme.defaultBigPadding
                Loader {
                    id: bottomRowLoader
                    Layout.fillWidth: root.bottomRowComponentFillsWidth
                }
                Item { Layout.fillWidth: true }
                StatusBadge {
                    visible: root.hasNotification
                    value: root.notificationsCount
                }
            }
        }

        // top right corner
        HomePageToolButton {
            objectName: "pinButton"
            anchors.right: parent.right
            anchors.rightMargin: -4
            anchors.top: parent.top
            anchors.topMargin: -4
            spacing: Theme.defaultHalfPadding
            visible: opacity > 0
            opacity: root.hovered || root.pinned ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: Theme.AnimationDuration.Fast } }
            action: pinAction
        }
    }

    StatusAction {
        id: pinAction
        objectName: "pinAction"
        icon.name: root.pinned ? "unpin" : "pin"
        text: root.pinned ? qsTr("Unpin") : qsTr("Pin")
        onTriggered: root.pinRequested()
    }

    Component {
        id: contextMenuComponent
        StatusMenu {
            id: contextMenu
            objectName: "homeGridItemContextMenu"
            StatusMenuInstantiator {
                model: [pinAction, ...root.extraMenuActions]
                menu: contextMenu
                delegate: StatusMenuItem {
                    action: modelData
                }
            }

            onClosed: destroy()
        }
    }
}

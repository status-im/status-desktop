import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import AppLayouts.Shell 1.0

AbstractButton {
    id: root

    /*required */property int sectionType // cf Constants.appSection.*

    property string itemId
    property string title
    property string subtitle
    property color color
    property url banner
    property bool hasNotification
    property int notificationsCount
    property alias bottomRowComponent: bottomRowLoader.sourceComponent
    property alias iconLoaderComponent: iconLoader.sourceComponent

    property bool pinned

    implicitWidth: 160
    implicitHeight: 160

    padding: 12

    icon.width: 48
    icon.height: 48

    signal pinRequested
    signal closeRequested

    function numberFormat(number) {
        var res = number
        const million = 1000000
        const ks = 1000
        if(number > million) {
            res = number / million
            res = Number(number / million).toLocaleString(root.locale, 'f', 1) + 'M'
        }
        else if(number > ks) {
            res = number / ks
            res = Number(number / ks).toLocaleString(root.locale, 'f', 1) + 'K'
        }
        else
            res = Number(number).toLocaleString(root.locale, 'f', 0)
        return res
    }

    background: Item {
        StatusRoundedImage {
            id: mainBgImage
            anchors.top: parent.top
            width: parent.width
            height: 40 + radius*2 // draw under the rect below
            color: root.color
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
            radius: Theme.padding
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

            color: hovered ? "#222833" : "#161c27"
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }

            radius: mainBgImage.radius
        }
    }

    contentItem: Item {
        // contents
        ColumnLayout {
            anchors.fill: parent
            Loader {
                id: iconLoader
                Layout.preferredWidth: root.icon.width
                Layout.preferredHeight: root.icon.height
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.weight: Font.DemiBold
                color: Theme.palette.white
                elide: Text.ElideRight

                HoverHandler {
                    id: titleTextHHandler
                    enabled: parent.truncated
                }
                StatusToolTip {
                    visible: titleTextHHandler.hovered
                    offset: -(x + width/2 - root.width/2)
                    color: "#161c27"
                    text: root.title
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: root.subtitle
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                color: Theme.palette.baseColor1
                elide: Text.ElideRight
            }
            Item {
                Layout.fillHeight: true
            }
            Loader {
                Layout.maximumWidth: parent.width - (badge.visible ? badge.width : 0)
                id: bottomRowLoader
                clip: badge.visible
            }
        }

        // top right corner
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: -4
            anchors.top: parent.top
            anchors.topMargin: -4
            spacing: Theme.halfPadding
            visible: opacity > 0
            opacity: root.hovered ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: Theme.AnimationDuration.Fast } }

            ShellToolButton {
                icon.name: root.pinned ? "unpin" : "pin"
                tooltipText: root.pinned ? qsTr("Unpin") : qsTr("Pin")
                onClicked: root.pinRequested()
            }
            ShellToolButton {
                icon.name: "close"
                tooltipText: qsTr("Close")
                onClicked: root.closeRequested()
            }
        }

        // bottom right corner
        StatusBadge {
            id: badge
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.notificationsCount ? 3 : 6
            visible: root.hasNotification
            value: root.notificationsCount
            color: Qt.darker(root.color, 1.33)
            radius: root.notificationsCount ? 6 : height/2
        }
    }

    HoverHandler {
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
    }
}

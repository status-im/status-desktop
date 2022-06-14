import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

Rectangle {
    id: statusBaseButton

    enum Size {
        Tiny,
        Small,
        Large
    }

    enum Type {
        Normal,
        Danger
    }

    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
    }

    property bool loading: false

    property alias hovered: sensor.containsMouse

    property int size: StatusBaseButton.Size.Large
    property int type: StatusBaseButton.Type.Normal

    property alias text: label.text
    property alias font: label.font

    property real defaultLeftPadding: size === StatusBaseButton.Size.Large ? 24 : 12
    property real defaultRightPadding: size === StatusBaseButton.Size.Large ? 24 : 12
    property real defaultTopPadding: {
        switch (size) {
            case StatusBaseButton.Size.Tiny:
              return 5
            case StatusBaseButton.Size.Small:
              return 10
            case StatusBaseButton.Size.Large:
            default:
              return 11
        }
    }
    property real defaultBottomPadding: {
        switch (size) {
            case StatusBaseButton.Size.Tiny:
              return 5
            case StatusBaseButton.Size.Small:
              return 10
            case StatusBaseButton.Size.Large:
            default:
              return 11
        }
    }


    property real leftPadding: defaultLeftPadding
    property real rightPadding: defaultRightPadding
    property real topPadding: defaultTopPadding
    property real bottomPadding: defaultBottomPadding

    property color normalColor
    property color hoverColor
    property color disaledColor

    property color textColor
    property color disabledTextColor

    signal pressed(var mouse)
    signal released(var mouse)
    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    property bool highlighted: false


    /// Implementation

    implicitWidth: sensor.width
    implicitHeight: sensor.height

    radius: size !== StatusBaseButton.Size.Tiny ? 8 : 6

    color: {
        if (statusBaseButton.enabled)
            return sensor.containsMouse || highlighted ? hoverColor
                                                       : normalColor;
        return disaledColor
    }

    QtObject {
        id: d
        readonly property color textColor: statusBaseButton.enabled ? statusBaseButton.textColor : statusBaseButton.disabledTextColor
    }

    MouseArea {
        id: sensor
        width: layout.width + statusBaseButton.leftPadding + statusBaseButton.rightPadding
        height: layout.height + statusBaseButton.topPadding + statusBaseButton.bottomPadding

        cursorShape: loading ? Qt.ArrowCursor
                             : Qt.PointingHandCursor

        hoverEnabled: true
        enabled: !loading && statusBaseButton.enabled

        Loader {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            active: loading
            sourceComponent: StatusLoadingIndicator {
                color: d.textColor
            } // Indicator
        } // Loader

        Row {
            id: layout
            anchors.left: parent.left
            anchors.leftMargin: statusBaseButton.leftPadding
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            StatusIcon {
                id: statusIcon
                width: statusBaseButton.icon.width
                height: statusBaseButton.icon.height
                icon: statusBaseButton.icon.name
                rotation: statusBaseButton.icon.rotation
                anchors.verticalCenter: parent.verticalCenter
                opacity: !loading && statusBaseButton.icon.name !== ""
                visible: statusBaseButton.icon.name !== ""
                color: d.textColor
            } // Icon
            StatusEmoji {
                width: statusBaseButton.icon.width
                height: statusBaseButton.icon.height
                anchors.verticalCenter: parent.verticalCenter
                visible: statusBaseButton.icon.emoji
                emojiId: Emoji.iconId(statusBaseButton.icon.emoji, statusBaseButton.icon.emojiSize) || ""
            } // Emoji
            StatusBaseText {
                id: label
                opacity: !loading
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: size === StatusBaseButton.Size.Large ? 15 : 13 // by design

                color: d.textColor
            } // Text
        } // Ro


        onPressed: {
            if (!loading) {
                statusBaseButton.pressed(mouse)
            }
        }

        onReleased: {
            if (!loading) {
                statusBaseButton.released(mouse)
            }
        }

        onClicked: {
            if (!loading) {
                statusBaseButton.clicked(mouse)
            }
        }

        onPressAndHold: {
            if (!loading) {
                statusBaseButton.pressAndHold(mouse)
            }
        }
    } // Sensor

}

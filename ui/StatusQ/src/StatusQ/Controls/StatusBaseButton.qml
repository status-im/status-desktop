import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Rectangle {
    id: statusBaseButton

    enum Size {
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
    property real defaultTopPadding: size === StatusBaseButton.Size.Large ? 11 : 10
    property real defaultBottomPadding: size === StatusBaseButton.Size.Large ? 11 : 10


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

    radius: 8

    color: {
        if (statusBaseButton.enabled) {
            return sensor.containsMouse || highlighted ? hoverColor
                                        : normalColor
        } else {
            return disaledColor
        }
    }


    MouseArea {
        id: sensor
        width: layout.width + statusBaseButton.leftPadding + statusBaseButton.rightPadding
        height: layout.height + statusBaseButton.topPadding + statusBaseButton.bottomPadding

        cursorShape: loading ? Qt.ArrowCursor
                             : Qt.PointingHandCursor
        hoverEnabled: !loading
        enabled: !loading

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
                anchors.verticalCenter: parent.verticalCenter
                visible: !loading && statusBaseButton.icon.name !== ""
                color: statusBaseButton.enabled ? textColor
                                                : disabledTextColor
            } // Icon
            StatusBaseText {
                id: label
                visible: !loading
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: size === StatusBaseButton.Size.Large ? 15 : 13 // by design

                color: statusBaseButton.enabled ? textColor
                                                : disabledTextColor
            } // Text

            Loader {
                anchors.verticalCenter: parent.verticalCenter
                active: loading
                sourceComponent: StatusLoadingIndicator {
                    color: statusBaseButton.enabled ? textColor
                                                    : disabledTextColor
                } // Indicator
            } // Loader
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

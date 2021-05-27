import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1


Rectangle {
    id: statusFlatRoundButton

    property StatusIconSettings icon: StatusIconSettings {
        width: 23
        height: 23

        color: {
            switch(statusFlatRoundButton.type) {
            case StatusFlatRoundButton.Type.Secondary:
                return Theme.palette.directColor1;
            case StatusFlatRoundButton.Type.Primary:
                return Theme.palette.primaryColor1;
            }
        }

        property color disabledColor: {
            switch(statusFlatRoundButton.type) {
            case StatusFlatRoundButton.Type.Secondary:
                return Theme.palette.baseColor1;
            case StatusFlatRoundButton.Type.Primary:
                return Theme.palette.baseColor1;
            }
        }
    }

    property bool loading: false

    property alias hovered: sensor.containsMouse

    property int type: StatusFlatRoundButton.Type.Primary

    signal pressed(var mouse)
    signal released(var mouse)
    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    enum Type {
        Primary,
        Secondary
    }



    /// Implementation

    QtObject {
        id: backgroundSettings

        property color color: {
            switch(statusFlatRoundButton.type) {
            case StatusFlatRoundButton.Type.Primary:
            case StatusFlatRoundButton.Type.Secondary:
                return "transparent";
            }
        }

        property color hoverColor: {
            switch(statusFlatRoundButton.type) {
            case StatusFlatRoundButton.Type.Primary:
                return Theme.palette.primaryColor3;
            case StatusFlatRoundButton.Type.Secondary:
                return Theme.palette.baseColor2;
            }
        }

        property color disabledColor: {
            switch(statusFlatRoundButton.type) {
            case StatusFlatRoundButton.Type.Primary:
            case StatusFlatRoundButton.Type.Secondary:
                return "transparent";
            }
        }
    }

    implicitWidth: 44
    implicitHeight: 44
    radius: 8

    color: {
        if (statusFlatRoundButton.enabled) {
            return sensor.containsMouse ? backgroundSettings.hoverColor
                                        : backgroundSettings.color
        } else {
            return backgroundSettings.disabledColor
        }
    }
    MouseArea {
        id: sensor

        anchors.fill: parent
        cursorShape: loading ? Qt.ArrowCursor
                             : Qt.PointingHandCursor
        hoverEnabled: !loading
        enabled: !loading


        StatusIcon {
            id: statusIcon
            anchors.centerIn: parent
            visible: !loading

            icon: statusFlatRoundButton.icon.name

            width: statusFlatRoundButton.icon.width
            height: statusFlatRoundButton.icon.height

            color: {
                if (statusFlatRoundButton.enabled) {
                    return statusFlatRoundButton.icon.color
                } else {
                    return statusFlatRoundButton.icon.disabledColor
                }
            }
        } // Icon
        Loader {
            active: loading
            anchors.centerIn: parent
            sourceComponent: StatusLoadingIndicator {
                color: {
                    if (statusFlatRoundButton.enabled) {
                        return statusFlatRoundButton.icon.color
                    } else {
                        return statusFlatRoundButton.icon.disabledColor
                    }
                }
            } // Indicator
        } // Loader

        onClicked: statusFlatRoundButton.clicked(mouse)
        onPressed: statusFlatRoundButton.pressed(mouse)
        onReleased: statusFlatRoundButton.released(mouse)
        onPressAndHold: statusFlatRoundButton.pressAndHold(mouse)
    } // Sensor
} // Rectangle

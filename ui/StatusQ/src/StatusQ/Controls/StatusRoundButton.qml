import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1


Rectangle {
    id: statusRoundButton

    property StatusIconSettings icon: StatusIconSettings {
        width: 23
        height: 23
        rotation: 0

        color: {
            switch(statusRoundButton.type) {
            case StatusRoundButton.Type.Primary:
                return Theme.palette.primaryColor1;
            case StatusRoundButton.Type.Secondary:
                return Theme.palette.indirectColor1;
            }
        }

        property color disabledColor: {
            switch(statusRoundButton.type) {
            case StatusRoundButton.Type.Primary:
                return Theme.palette.baseColor1;
            case StatusRoundButton.Type.Secondary:
                return Theme.palette.indirectColor1;
            }
        }
    }

    property bool loading: false

    property alias hovered: sensor.containsMouse

    property bool highlighted: false

    property int type: StatusRoundButton.Type.Primary

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
            switch(statusRoundButton.type) {
            case StatusRoundButton.Type.Primary:
                return Theme.palette.primaryColor3;
            case StatusRoundButton.Type.Secondary:
                return Theme.palette.primaryColor1;
            }
        }

        property color hoverColor: {
            switch(statusRoundButton.type) {
            case StatusRoundButton.Type.Primary:
                return Theme.palette.primaryColor2;
            case StatusRoundButton.Type.Secondary:
                return Theme.palette.miscColor1;
            }
        }

        property color disabledColor: {
            switch(statusRoundButton.type) {
            case StatusRoundButton.Type.Primary:
                return Theme.palette.indirectColor1;
            case StatusRoundButton.Type.Secondary:
                return Theme.palette.baseColor1;
            }
        }
    }

    implicitWidth: 44
    implicitHeight: 44
    radius: width / 2;

    color: {
        if (statusRoundButton.enabled) {
            return sensor.containsMouse || highlighted ? backgroundSettings.hoverColor
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

            icon: statusRoundButton.icon.name
            rotation: statusRoundButton.icon.rotation

            width: statusRoundButton.icon.width
            height: statusRoundButton.icon.height

            color: {
                if (statusRoundButton.enabled) {
                    return statusRoundButton.icon.color
                } else {
                    return statusRoundButton.icon.disabledColor
                }
            }
        } // Icon
        Loader {
            active: loading
            anchors.centerIn: parent
            sourceComponent: StatusLoadingIndicator {
                color: {
                    if (statusRoundButton.enabled) {
                        return statusRoundButton.icon.color
                    } else {
                        return statusRoundButton.icon.disabledColor
                    }
                }
            } // Indicator
        } // Loader

        onClicked: statusRoundButton.clicked(mouse)
        onPressed: statusRoundButton.pressed(mouse)
        onReleased: statusRoundButton.released(mouse)
        onPressAndHold: statusRoundButton.pressAndHold(mouse)
    } // Sensor
} // Rectangle

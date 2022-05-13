import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

ProgressBar {
    id: control

    property string text
    property color fillColor
    property color backgroundColor: Theme.palette.directColor8
    property color backgroundBorderColor: "transparent"

    width: 416
    height: 16
    clip: true

    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
        color: control.backgroundColor
        border.color: control.backgroundBorderColor
        radius: 5
    }
    contentItem: Item {
        implicitHeight: parent.height

        Rectangle {
            id: bar
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.fillColor
            radius: 5

            StatusBaseText {
                id: textItem
                anchors.centerIn: parent
                property bool _fittedInBar: width < bar.width ? true : false
                text: control.text
                font.pixelSize: 12
                color: Theme.palette.indirectColor1
                Component.onCompleted: opacity = width < bar.width ? 1 : 0
                on_FittedInBarChanged: {
                    if (_fittedInBar && opacity == 0) {
                        fadeIn.start();
                    }
                    else if (!_fittedInBar) {
                        fadeIn.stop();
                        opacity = 0;
                    }
                }

                OpacityAnimator { id: fadeIn; target: textItem; from: 0; to: 1; duration: 250 }
            }
        }
    }
}

import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

CheckBox {
    id: root

    property bool leftSide: true

    font.family: Theme.palette.baseFont.name

    indicator: Rectangle {
        anchors.left: root.leftSide? parent.left : undefined
        anchors.right: !root.leftSide? parent.right : undefined
        implicitWidth: 18
        implicitHeight: 18
        x: !root.leftSide? root.rightPadding : root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 2
        color: (root.down || root.checked) ? Theme.palette.primaryColor1
                                           : Theme.palette.directColor8

        StatusIcon {
            icon: "checkbox"
            width: 11
            height: 8
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            color: Theme.palette.white
            visible: root.down || root.checked
        }
    }

    contentItem: StatusBaseText {
        text: root.text
        font: root.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
        color: Theme.palette.directColor1
        lineHeight: 1.2
        leftPadding: root.leftSide? (!!root.text ? root.indicator.width + root.spacing
                                 : root.indicator.width) : 0
        rightPadding: !root.leftSide? (!!root.text ? root.indicator.width + root.spacing
                                 : root.indicator.width) : 0
    }
}

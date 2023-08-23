import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1

RowLayout {
    id: root

    height: 40

    property string order: ""
    property string orderColor: ""
    property string text1: ""
    property string text1Color: ""
    property string icon: ""
    property string text2: ""
    property string text2Color: ""
    property string text3: ""
    property string text3Color: ""

    StatusBaseText {
        Layout.alignment: Qt.AlignVCenter
        visible: !!root.order
        color: root.orderColor
        text: root.order
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignVCenter
        visible: !!root.text1
        color: root.text1Color
        text: "%1".arg(root.text1)
    }
    StatusRoundIcon {
        visible: !!root.icon
        asset.name: root.icon
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignVCenter
        visible: !!root.text2
        color: root.text2Color
        text: "%1".arg(root.text2)
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignVCenter
        visible: !!root.text3
        color: root.text3Color
        text: "%1".arg(root.text3)
    }
}

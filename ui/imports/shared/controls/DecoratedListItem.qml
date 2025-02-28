import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

RowLayout {
    id: root

    height: 40

    property string order: ""
    property color orderColor: Theme.palette.baseColor1
    property string text1: ""
    property color text1Color: Theme.palette.baseColor1
    property string icon: ""
    property alias asset: icon1.asset
    property string text2: ""
    property string text2Color: ""
    property string text3: ""
    property color text3Color: Theme.palette.baseColor1
    property string text4: ""
    property color text4Color: Theme.palette.baseColor1
    property string text5: ""
    property color text5Color: Theme.palette.baseColor1

    StatusBaseText {
        visible: text
        color: root.orderColor
        text: root.order
    }
    StatusBaseText {
        visible: text
        color: root.text1Color
        text: root.text1
    }
    StatusRoundIcon {
        id: icon1
        visible: !!root.icon
        asset.name: root.icon
    }
    StatusBaseText {
        visible: text
        color: root.text2Color
        text: root.text2
    }
    StatusBaseText {
        visible: text
        color: root.text3Color
        text: root.text3
    }
    StatusBaseText {
        visible: text
        color: root.text4Color
        text: root.text4
    }
    StatusBaseText {
        visible: text
        color: root.text5Color
        text: root.text5
    }
}

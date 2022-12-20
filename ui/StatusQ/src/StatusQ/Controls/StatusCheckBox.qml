import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

CheckBox {
    id: root

    /*!
       \qmlproperty int StatusCheckBox::size
       This property holds size type of the radio button.
       Possible values are:
       - Small
       - Regular (default size)
    */
    property int size: StatusCheckBox.Size.Regular

    enum Size {
        Small,
        Regular
    }

    property bool leftSide: true

    QtObject {
        id: d

        readonly property int indicatorSizeRegular: 18
        readonly property int indicatorSizeSmall: 12

        readonly property int indicatorIconWidthRegular: 11
        readonly property int indicatorIconWidthSmall: 7

        readonly property int indicatorIconHeightRegular: 8
        readonly property int indicatorIconHeightSmall: 5
    }

    font.family: Theme.palette.baseFont.name

    indicator: Rectangle {
        anchors.left: root.leftSide? parent.left : undefined
        anchors.right: !root.leftSide? parent.right : undefined
        implicitWidth: size === StatusCheckBox.Size.Regular
                       ? d.indicatorSizeRegular : d.indicatorSizeSmall
        implicitHeight: implicitWidth
        x: !root.leftSide? root.rightPadding : root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 2
        color: (root.down || root.checked) ? Theme.palette.primaryColor1
                                           : Theme.palette.directColor8

        StatusIcon {
            icon: "checkbox"
            width: size === StatusCheckBox.Size.Regular
                   ? d.indicatorIconWidthRegular : d.indicatorIconWidthSmall
            height: size === StatusCheckBox.Size.Regular
                    ? d.indicatorIconHeightRegular : d.indicatorIconHeightSmall
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

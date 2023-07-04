import QtQuick 2.15
import QtQuick.Controls 2.15

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
    property bool changeCursor: true

    enum Size {
        Small,
        Regular
    }

    property bool leftSide: true

    opacity: enabled ? 1.0 : 0.3

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
        color: root.down || checkState !== Qt.Checked
                    ? Theme.palette.directColor8
                    : Theme.palette.primaryColor1

        StatusIcon {
            icon: "checkbox"
            width: size === StatusCheckBox.Size.Regular
                   ? d.indicatorIconWidthRegular : d.indicatorIconWidthSmall
            height: size === StatusCheckBox.Size.Regular
                    ? d.indicatorIconHeightRegular : d.indicatorIconHeightSmall
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            color: checkState === Qt.PartiallyChecked ? Theme.palette.directColor9 : Theme.palette.white
            visible: root.down || checkState !== Qt.Unchecked
        }
    }

    contentItem: StatusBaseText {
        text: root.text
        font: root.font
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
        color: Theme.palette.directColor1
        lineHeight: 1.2
        leftPadding: root.leftSide? (!!root.text ? root.indicator.width + root.spacing
                                 : root.indicator.width) : 0
        rightPadding: !root.leftSide? (!!root.text ? root.indicator.width + root.spacing
                                 : root.indicator.width) : 0
        visible: !!text
    }

    HoverHandler {
        acceptedDevices: PointerDevice.Mouse
        cursorShape: Qt.PointingHandCursor
    }
}

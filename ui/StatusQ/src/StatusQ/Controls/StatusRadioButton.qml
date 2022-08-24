import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1


RadioButton {
    id: statusRadioButton

    /*!
       \qmlproperty int StatusRadioButton::size
       This property holds size type of the radio button.
       Possible values are:
       - Small
       - Large (default size)
    */
    property int size: StatusRadioButton.Size.Large

    enum Size {
        Small,
        Large
    }

    width: indicator.implicitWidth

    indicator: Rectangle {
        implicitWidth: size === StatusRadioButton.Size.Large ? 20 : 14
        implicitHeight: size === StatusRadioButton.Size.Large ? 20 : 14
        x: 0
        y: 6
        radius: 10
        color: statusRadioButton.checked ? Theme.palette.primaryColor1
                                         : Theme.palette.directColor8

        Rectangle {
            width: size === StatusRadioButton.Size.Large ? 12 : 8
            height: size === StatusRadioButton.Size.Large ? 12 : 8
            radius: 6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: statusRadioButton.checked ? Theme.palette.white : "transparent"
            visible: statusRadioButton.checked
        }
    }
    contentItem: StatusBaseText {
        text: statusRadioButton.text
        color: Theme.palette.directColor1
        verticalAlignment: Text.AlignVCenter
        leftPadding: !!statusRadioButton.text ? statusRadioButton.indicator.width + statusRadioButton.spacing
                                              : statusRadioButton.indicator.width
    }
}

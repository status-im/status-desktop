import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0

StatusListItem {
    id: root

    property ButtonGroup buttonGroup
    property alias checked: radioButton.checked
    readonly property alias radioButton: radioButton

    implicitHeight: 44
    leftPadding: 8
    rightPadding: 9
    statusListItemTitle.font.pixelSize: 13

    statusListItemTitleArea.anchors.leftMargin: 8

    asset.bgWidth: 32
    asset.bgHeight: 32

    Binding on asset.color {
        when: !root.enabled
        value: Style.current.darkGrey
    }

    components: [
        StatusRadioButton {
            id: radioButton

            visible: root.enabled

            // reference to root for better integration with ButtonGroup
            // by accessing main component via ButtonGroup::checkedButton.item
            readonly property alias item: root

            size: StatusRadioButton.Size.Small
            ButtonGroup.group: root.buttonGroup

            rightPadding: 0
        }
    ]

    // using MouseArea instead of build-in 'clicked' signal to avoid
    // intercepting event by the StatusRadioButton
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!radioButton.checked)
                radioButton.toggle()
        }
        cursorShape: Qt.PointingHandCursor
    }
}

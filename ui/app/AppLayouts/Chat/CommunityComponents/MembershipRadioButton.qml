import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "."

Item {
    property string text
    property string description
    property var buttonGroup
    property bool checked: false
    property bool hideSeparator: false
    signal radioCheckedChanged(bool checked)

    id: root
    width: parent.width
    height: childrenRect.height

    StatusRadioButtonRow {
        id: radioBtn
        text: root.text
        buttonGroup: root.buttonGroup
        checked: root.checked
        onRadioCheckedChanged: {
            root.radioCheckedChanged(checked)
        }
    }

    StyledText {
        id: radioDesc
        text: root.description
        anchors.top: radioBtn.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 100
        font.pixelSize: 13
        color: Style.current.secondaryText
        wrapMode: Text.WordWrap
    }

    Separator {
        visible: !root.hideSeparator
        anchors.top: radioDesc.bottom
        anchors.topMargin: visible ? Style.current.halfPadding : 0
    }
}

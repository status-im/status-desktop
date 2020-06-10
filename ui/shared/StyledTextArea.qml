import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import "../imports"

Item {
    property alias textField: textArea
    property string placeholderText: "My placeholder"
    property alias text: textArea.text
    //    property string label: "My Label"
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Theme.grey
    readonly property var forceActiveFocus: function () {
        textArea.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7
    property int customHeight: 44

    id: inputBox
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0)
    anchors.right: parent.right
    anchors.left: parent.left

    Text {
        id: inputLabel
        text: inputBox.label
        font.weight: Font.Medium
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 13
        color: Theme.black
    }

    Rectangle {
        id: inputRectangle
        height: customHeight
        color: bgColor
        radius: 8
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left

        TextArea {
            id: textArea
            text: ""
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            placeholderText: inputBox.placeholderText
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: inputBox.hasIcon ? 36 : Theme.padding
            anchors.bottomMargin: Theme.smallPadding
            anchors.topMargin: Theme.smallPadding
            anchors.fill: parent

        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            textArea.forceActiveFocus(Qt.MouseFocusReason)
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/


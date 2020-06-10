import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import "../imports"

Item {
    //    property string label: "My Label"
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Theme.grey
    readonly property int labelMargin: 7
    property var selectOptions
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

        Menu {
            id: selectMenu
            width: parent.width
            padding: 10
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: Theme.grey
                radius: Theme.radius
            }
            Component.onCompleted: {
                if (!selectOptions) {
                    return
                }

                selectOptions.forEach(function (element) {
                    var item = menuItem.createObject(undefined, element)
                    selectMenu.addItem(item)
                })
            }

            Component {
                id: menuItem
                MenuItem {
                    property var onClicked: console.log("Default click function. Override me please")
                    property color bgColor: Theme.white
                    anchors.right: parent.right
                    anchors.left: parent.left
                    onTriggered: function () {
                        onClicked()
                    }
                    background: Rectangle {
                        color: bgColor
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            selectMenu.open()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/


import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import "../imports"

Item {
    property alias textField: inputValue
    property string placeholderText: "My placeholder"
    property alias text: inputValue.text
    property string label: ""

//    property string label: "My Label"
//    property url icon: "../app/img/hash.svg"
    property bool isSelect: false
    property url icon: ""
    readonly property bool hasIcon: icon.toString() !== ""
    readonly property bool hasLabel: label !== ""
    readonly property var forceActiveFocus: function () {
        inputValue.forceActiveFocus(Qt.MouseFocusReason)
    }
    readonly property int labelMargin: 7

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
        height: 44
        color: Theme.grey
        radius: 8
        anchors.top: inputBox.hasLabel ? inputLabel.bottom : parent.top
        anchors.topMargin: inputBox.hasLabel ? inputBox.labelMargin : 0
        anchors.right: parent.right
        anchors.left: parent.left

        TextField {
            id: inputValue
            visible: !isSelect
            placeholderText: inputBox.placeholderText
            text: inputBox.text
            anchors.left: parent.left
            anchors.leftMargin: inputBox.hasIcon ? 36 : Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
            background: Rectangle {
                color: "#00000000"
            }
        }

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
            property var elements: [
                {
                    text: "Element 1",
                    onTriggered: function () {
                        console.log("Allo 1")
                    }
                },
                {
                    text: "Element 2",
                    onTriggered: function () {
                        console.log("Allo 2")
                    }
                }
            ]
            Component.onCompleted: {
                elements.forEach(element => {
                    addItem(menuItem.createObject(selectMenu, element))
                })
            }

             Component {
                 id: menuItem
                 MenuItem {
                     anchors.right: parent.right
                     anchors.left: parent.left
                     background: Rectangle {
                        color: Theme.white
                     }
                 }
             }

//            MenuItem {
//                text: "New..."
//                anchors.right: parent.right
//                anchors.left: parent.left
////                onTriggered: document.reset()
//                background: Rectangle {
//                   color: Theme.white
//                }
//            }
        }

        Image {
            id: iconImg
            sourceSize.height: 24
            sourceSize.width: 24
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: inputBox.icon
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            isSelect ? selectMenu.open() : inputValue.forceActiveFocus(Qt.MouseFocusReason)
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/


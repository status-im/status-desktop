import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    property string label: ""
    readonly property bool hasLabel: label !== ""
    property color bgColor: Theme.grey
    readonly property int labelMargin: 7
    property var selectOptions
    property int customHeight: 44
    property string selectedText: ""

    id: inputBox
    height: inputRectangle.height + (hasLabel ? inputLabel.height + labelMargin : 0)
    anchors.right: parent.right
    anchors.left: parent.left

    StyledText {
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

        StyledText {
            id: selectedTextField
            visible: inputBox.selectedText !== ""
            text: inputBox.selectedText
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
        }

        SVGImage {
            id: caret
            width: 11
            height: 6
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "../app/img/caret.svg"
        }
        ColorOverlay {
            anchors.fill: caret
            source: caret
            color: Theme.darkGrey
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

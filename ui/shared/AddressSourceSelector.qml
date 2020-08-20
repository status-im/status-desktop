import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property var sources: []
    property string selectedSource: sources[0] || "Address"
    property int dropdownWidth: 220
    property var reset: function() {}
    height: select.height

    function resetInternal() {
        sources = []
        selectedSource = sources[0] || "Address"
    }

    Select {
        id: select
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.sources
        selectedItemView: Item {
            anchors.fill: parent
            StyledText {
                id: selectedTextField
                text: root.selectedSource
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                verticalAlignment: Text.AlignVCenter
                height: 24
            }
        }
        menu.width: dropdownWidth
        menu.topPadding: 8
        menu.bottomPadding: 8
        menu.delegate: Component {
            MenuItem {
                id: menuItem
                height: 40
                width: parent.width
                onTriggered: function () {
                    root.selectedSource = root.sources[index]
                }

                StyledText {
                    id: itemText
                    text: root.sources[index]
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    height: 22
                    color: menuItem.highlighted ? Style.current.primaryMenuItemTextHover : Style.current.textColor
                }
                background: Rectangle {
                    color: menuItem.highlighted ? Style.current.primaryMenuItemHover : Style.current.transparent
                }
            }
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property var sources: []
    property var selectedSource: sources.length ? sources[0] : null
    property int dropdownWidth: 220
    height: select.height

    Select {
        id: select
        anchors.left: parent.left
        anchors.right: parent.right
        model: root.sources
        selectedItemView: Item {
            anchors.fill: parent
            StyledText {
                id: selectedTextField
                text: !!root.selectedSource ? root.selectedSource.text : qsTr("Invalid source")
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
                    text: root.sources[index].text
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

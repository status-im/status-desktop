import QtQuick 2.1
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

Rectangle {
    property bool isVisible: false

    id: root
    visible: isVisible && !!listView.count
    color: Style.current.background
    width: parent.width
    height: 56
    border.width: 1
    border.color: Style.current.border

    // This container is to contain the downloaded elements between the parent buttons and hide the overflow
    Item {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: showAllBtn.left
        anchors.rightMargin: Style.current.smallPadding
        height: listView.height
        clip: true

        ListView {
            id: listView
            orientation: ListView.Horizontal
            model: downloadModel
            height: currentItem ? currentItem.height : 0
            // This makes it show the newest on the right
            layoutDirection: Qt.RightToLeft
            spacing: Style.current.smallPadding
            anchors.left: parent.left
            width: {
                // Children rect shows a warning but this works ¯\_(ツ)_/¯
                let w = 0
                for (let i = 0; i < count; i++) {
                    w += this.itemAtIndex(i).width + this.spacing
                }
                return w
            }
            interactive: false
            delegate: Component {
                DownloadElement {}
            }
        }
    }


    StatusButton {
        id: showAllBtn
        size: "small"
        text: qsTr("Show All")
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: closeBtn.left
        anchors.rightMargin: Style.current.padding
        onClicked: {
            addNewDownloadTab()
        }
    }

    StatusIconButton {
        id: closeBtn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        icon.name: "browser/close"
        iconColor: Style.current.textColor
        onClicked: {
            root.isVisible = false
        }
    }
}

/*##^##
Designer {
    D{i:0;height:56;width:700}
}
##^##*/

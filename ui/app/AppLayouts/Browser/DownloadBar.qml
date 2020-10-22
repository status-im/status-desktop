import QtQuick 2.1
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

//downloadModel.downloads[index].receivedBytes

Rectangle {
    id: root
    visible: false
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
            spacing: Style.current.smallPadding
            width: parent.width
            interactive: false
            delegate: Component {
                DownloadElement {
                }
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
            downloadView.visible = true
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
            root.visible = false
        }
    }
}

/*##^##
Designer {
    D{i:0;height:56;width:700}
}
##^##*/

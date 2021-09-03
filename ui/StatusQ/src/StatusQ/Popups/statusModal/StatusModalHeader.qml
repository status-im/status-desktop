import QtQuick 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: statusModalHeader

    property alias title: imageWithTitle.title
    property alias subTitle: imageWithTitle.subTitle
    property int titleElide
    property int subTitleElide
    property alias actionButton: actionButtonLoader.sourceComponent

    property alias image: imageWithTitle.image
    property alias icon: imageWithTitle.icon
    property bool editable: false
    property Component popupMenu

    signal editButtonClicked
    signal close

    implicitHeight: visible? Math.max(closeButton.height, imageWithTitle.implicitHeight) + 32 : 0
    implicitWidth: 480

    radius: 16

    color: Theme.palette.statusModal.backgroundColor

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    StatusImageWithTitle {
        id: imageWithTitle
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: actionButtonLoader.left
        anchors.leftMargin: 16

        editable: statusModalHeader.editable
        titleElide: statusModalHeader.titleElide
        subTitleElide: statusModalHeader.subTitleElide
        onEditButtonClicked: statusModalHeader.editButtonClicked()
    }

    MouseArea {
        anchors.fill: imageWithTitle
        visible: !!statusModalHeader.popupMenu
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popupMenuSlot.item.popup(imageWithTitle.x, imageWithTitle.y + imageWithTitle.height + 8)
        }
    }

    Loader {
        id: actionButtonLoader
        anchors.right: closeButton.left
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 16
    }

    StatusFlatRoundButton {
        id: closeButton
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 16
        width: 32
        height: 32
        type: StatusFlatRoundButton.Type.Secondary
        icon.name: "close"
        icon.color: Theme.palette.directColor1
        icon.width: 20
        icon.height: 20

        onClicked: statusModalHeader.close()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.radius
        color: parent.color

        StatusModalDivider {
            anchors.bottom: parent.bottom
            width: parent.width
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusModalHeader.popupMenu
    }
}

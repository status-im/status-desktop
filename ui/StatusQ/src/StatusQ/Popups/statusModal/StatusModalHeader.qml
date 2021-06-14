import QtQuick 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusModalHeader

    property alias title: imageWithTitle.title
    property alias subTitle: imageWithTitle.subTitle
    property alias actionButton: actionButtonLoader.sourceComponent

    property alias image: imageWithTitle.image
    property bool editable: false

    signal editClicked
    signal close

    implicitHeight: imageWithTitle.implicitHeight + 32
    implicitWidth: 480

    radius: 16

    color: Theme.palette.statusModal.backgroundColor


    StatusImageWithTitle {
        id: imageWithTitle
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16

        editable: statusModalHeader.editable
        onEditButtonClicked: statusModalHeader.editButtonClicked()
    }

    Loader {
        id: actionButtonLoader
        anchors.right: closeButton.left
        anchors.rightMargin: 24.5
        anchors.top: parent.top
        anchors.topMargin: 18

        type: StatusFlatRoundButton.Type.Secondary
        width: 20
        height: 20

        icon.width: detailsButtonSettings.width
        icon.height: detailsButtonSettings.height
        icon.name: detailsButtonSettings.name
        icon.color: detailsButtonSettings.color

        onClicked: statusModalHeader.detailsClicked()
    }

    StatusFlatRoundButton {
        id: closeButton
        anchors.right: parent.right
        anchors.rightMargin: 22.5
        anchors.top: parent.top
        anchors.topMargin: 22.5
        width: 11.5
        height: 11.5
        type: StatusFlatRoundButton.Type.Secondary
        icon.name: "close"
        icon.color: Theme.palette.directColor1

        onClicked: statusModalHeader.close()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.radius
        color: parent.color
    }
}

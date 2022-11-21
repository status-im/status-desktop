import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    property alias source: image.source

    Rectangle {
        anchors.fill: parent
        color: "lightgray"
    }

    Flickable {
        anchors.fill: parent

        contentWidth: image.implicitWidth
        contentHeight: image.implicitHeight

        clip: true

        ScrollIndicator.vertical: ScrollIndicator {}
        ScrollIndicator.horizontal: ScrollIndicator {}

        Image {
            id: image
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: image.status !== Image.Ready
    }
}

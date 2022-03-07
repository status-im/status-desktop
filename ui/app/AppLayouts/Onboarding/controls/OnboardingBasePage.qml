import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1

import utils 1.0

Page {
    id: root
    signal backClicked()
    signal finished()

    background: Rectangle {
        color: Style.current.background
    }

    StatusRoundButton {
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        icon.name: "arrow-left"
        onClicked: {
            root.backClicked();
        }
    }
}

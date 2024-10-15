import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Page {
    id: root

    property alias backButtonVisible: backButton.visible

    signal backClicked()

    background: Rectangle {
        color: Theme.palette.background
    }

    StatusRoundButton {
        id: backButton
        objectName: "onboardingBackButton"
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        icon.name: "arrow-left"
        onClicked: {
            root.backClicked();
        }
    }
}

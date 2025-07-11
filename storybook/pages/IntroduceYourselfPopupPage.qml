import QtQuick
import QtQuick.Controls

import Storybook

import shared.popups

Item {
    Button {
        anchors.centerIn: parent
        text: "Reopen"
        onClicked: popup.open()
    }

    IntroduceYourselfPopup {
        id: popup
        visible: true

        pubKey: "zQ3shW234234EA4545545rhf"
        colorId: 0
        colorHash: [{colorId: 9, segmentLength: 1}, {colorId: 7, segmentLength: 3}, {colorId: 10, segmentLength: 2}]
        onAccepted: console.warn("onAccepted")
        onClosed: console.warn("onClosed")
    }
}

// category: Popups
// status: good

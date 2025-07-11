import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import shared.popups.walletconnect

SplitView {

    Rectangle {
        anchors.fill: parent
        color: "lightgray"
    }

    DAppsUriCopyInstructionsPopup {
        visible: true
        modal: false
        anchors.centerIn: parent
        destroyOnClose: false
    }
}

// category: Popups
// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=3649-30334&t=r8RYxCglhi5DYQos-0

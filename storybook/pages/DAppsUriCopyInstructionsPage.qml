import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0

import shared.popups.walletconnect 1.0

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

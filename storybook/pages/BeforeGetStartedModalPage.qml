import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import AppLayouts.Onboarding.popups 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    function openDialog() {
        popupComponent.createObject(popupBg)
    }

    Component.onCompleted: openDialog()

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: openDialog()
            }
        }
    }

    Component {
        id: popupComponent
        BeforeGetStartedModal {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true
            onClosed: destroy()
        }
    }
}

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?type=design&node-id=38555-18004&mode=design&t=WHoI8vkSC9JScbPx-0

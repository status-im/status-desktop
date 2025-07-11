import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ.Core.Theme

import AppLayouts.Communities.popups

import utils

import Storybook

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
        ImportControlNodePopup {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true
            community: QtObject {
                property string id: "1"
                property string name: "Socks"
                property var members: { "count": 5 }
                property string image: Theme.png("tokens/UNI")
                property string color: "orchid"
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}

// category: Popups

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=36894-685104&mode=design&t=6k1ago8SSQ5Ip9J8-0

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQml

import Qt.labs.platform

import Status.ChatSection

import Status.Containers
import Status.Controls.Navigation

PanelAndContentBase {
    id: root

    required property string sectionId

    implicitWidth: 1232
    implicitHeight: 770

    ChatSectionController {
        id: chatSectionController
    }

    Component.onCompleted: {
        chatSectionController.init(root.sectionId)
    }

    RowLayout {
        id: mainLayout

        anchors.fill: parent

        NavigationView {
            id: panel

            Layout.preferredWidth: root.panelWidth
            Layout.fillHeight: true

            chatSectionController: chatSectionController
        }

        ContentView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            selectedChat: chatSectionController.currentChat
            chatSectionController: chatSectionController
        }
    }
}

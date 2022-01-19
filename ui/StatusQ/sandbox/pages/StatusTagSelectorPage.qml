import QtQuick 2.14

import StatusQ.Components 0.1

Item {
    id: root
    anchors.fill: parent

    property ListModel asortedContacts: ListModel {
        ListElement {
            publicId: "0x0"
            name: "Maria"
            icon: ""
            isIdenticon: false
            onlineStatus: 3
        }
        ListElement {
            publicId: "0x1"
            name: "James"
            icon: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            isIdenticon: false
            onlineStatus: 1
        }
        ListElement {
            publicId: "0x2"
            name: "Paul"
            icon: ""
            isIdenticon: false
            onlineStatus: 2
        }
        ListElement {
            publicId: "0x3"
            name: "Tracy"
            icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            isIdenticon: true
            onlineStatus: 3
        }
        ListElement {
            publicId: "0x4"
            name: "Nick"
            icon: ""
            isIdenticon: false
            onlineStatus: 3
        }
    }

    StatusTagSelector {
        id: tagSelector
        width: 650
        height: 44
        anchors.centerIn: parent
        namesModel: root.asortedContacts
        toLabelText: qsTr("To: ")
        warningText: qsTr("5 USER LIMIT REACHED")
    }
}

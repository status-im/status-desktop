import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property alias model: listView.model

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    signal removeClicked(int index)
    signal removeAllClicked
    signal addClicked

    function getNewUser(seed: int) {
         const pubKey = "0x%1".arg(seed)
         return {
             pubKey: pubKey,
             compressedPubKey: "compressed_" + pubKey,
             displayName: seed%8 ? "_user%1".arg(seed) : "",
             preferredDisplayName: "user%1".arg(seed),
             localNickname: seed%3 ? "" : "nickname%1".arg(seed),
             alias: "three word name(%1)".arg(pubKey),
             isVerified: seed%3 ? false : true,
             isUntrustworthy: seed%5 ? false : true,
             isContact: true,
             icon: "",
             color: seed%2 ? "white" : "red",
             onlineStatus: seed%2,
             isAdmin: seed%2 ? true : false,
             ensName: "",
             colorId: 7
         }
     }

    ColumnLayout {
        id: layout

        anchors.fill: parent

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: 32

            delegate: ColumnLayout {
                id: delegate

                spacing: 0
                width: ListView.view.width

                Row {
                    Label {
                        width: delegate.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "displayName:\t"
                    }
                    TextField {
                        width: delegate.width / 2
                        text: model.displayName
                        onTextEdited: model.displayName = text
                    }
                }
                Row {
                    Label {
                        width: delegate.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "localNickname:\t"
                    }
                    TextField {
                        width: delegate.width / 2
                        text: model.localNickname
                        onTextEdited: model.localNickname = text
                    }
                }
                Row {
                    Label {
                        width: delegate.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "isVerified:\t"
                    }
                    Switch {
                        width: delegate.width / 2
                        checked: model.isVerified
                        onToggled: model.isVerified = checked
                    }
                }
                Row {
                    Label {
                        width: delegate.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "isUntrustworthy:\t"
                    }
                    Switch {
                        width: delegate.width / 2
                        checked: model.isUntrustworthy
                        onToggled: model.isUntrustworthy = checked
                    }
                }
                Row {
                    Label {
                        width: delegate.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: "onlineStatus:\t"
                    }
                    SpinBox {
                        width: delegate.width / 2
                        from: 0
                        to: 1
                        value: model.onlineStatus
                        onValueModified: model.onlineStatus = value
                    }
                }
                Button {
                    text: "remove"
                    onClicked: root.removeClicked(index)
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        Button {
            Layout.fillWidth: true
            text: "remove all"
            onClicked: root.removeAllClicked()
        }

        Button {
            Layout.fillWidth: true
            text: "add"
            onClicked: root.addClicked()
        }
    }
}

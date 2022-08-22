import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Page {
    id: root
    anchors.fill: parent
    anchors.margins: 16
    property ListModel contactsModel: null
    background: null

    header: RowLayout {
        id: headerRow
        width: parent.width
        height: tagSelector.height
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 16

        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            maxHeight: root.height
            toLabelText: qsTr("To: ")
            warningText: qsTr("USER LIMIT REACHED")
            listLabel: qsTr("Contacts")
            ringSpecModelGetter: function(pubKey) {
                //for simulation purposes only, in real app
                //this would be Utils.getColorHashAsJson(pubKey)
                var index = -1;
                if (!!contactsModel) {
                    for (var i = 0; i < contactsModel.count; i++) {
                        if (contactsModel.get(i).pubKey === pubKey) {
                            index = i;
                        }
                    }
                    return contactsModel.get(index).ringSpecModel;
                } else {
                    return null;
                }
            }
            compressedKeyGetter: function(pubKey) {
                //for simulation purposes only, in real app
                //this would be Utils.getCompressedPk(pubKey);
                var possibleCharacters = pubKey.split('');
                var randomStringLength = 12; // assuming you want random strings of 12 characters
                var randomString = [];
                for (var i=0; i<randomStringLength; ++i) {
                    var index = (Math.random() * possibleCharacters.length).toFixed(0);
                    var nextChar = possibleCharacters[index];
                    randomString.push(nextChar);
                }
                return randomString.join().toString().replace(/,/g, '');
            }
            colorIdForPubkeyGetter: function (pubKey) {
                //for simulation purposes only, in real app
                //this would be Utils.colorIdForPubkey(pubKey);
                return Math.floor(Math.random() * 10);
            }
            onTextChanged: {
                sortModel(root.contactsModel);
            }
            Component.onCompleted: {
                textEdit.forceActiveFocus();
                sortModel(root.contactsModel);
            }
        }

        StatusButton {
            implicitWidth: 106
            implicitHeight: 44
            Layout.alignment: Qt.AlignTop
            enabled: (tagSelector.namesModel.count > 0)
            text: "Confirm"
        }

        Item {
            implicitHeight: 32
            implicitWidth: 32
            Layout.alignment: Qt.AlignTop

            StatusActivityCenterButton {
                id: notificationButton
                anchors.right: parent.right
                unreadNotificationsCount: 3
            }
        }
    }

    contentItem: Item {
        anchors.fill: parent

        StatusBaseText {
            width: Math.min(553, parent.width - 32)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -(headerRow.height/2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: contactsModel.count === 0
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts.\n
Send a contact request to the person you would like to chat with, you will be able to chat with them once they have accepted your contact request.")
            Component.onCompleted: {
                if (visible) {
                    tagSelector.enabled = false;
                }
            }
        }
    }
}

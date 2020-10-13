import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    id: popup
    property var selectedAddresses: []
    property bool userListMode: false

    function resetSelectedMembers(){
        const request = {
            type: "getOperators",
            payload: utilsModel.channelHash(chatsModel.activeChannel.name)
        }

        const members = profileModel.contactList
        const memberLength = members.rowCount()
        const pubKeyByAddress = {}
        let pubKey, address;
        for(let i = 0; i < memberLength; i++) {
            pubKey = members.rowData(i, "pubKey")
            address = utilsModel.derivedAnUserAddress(pubKey)
            pubKeyByAddress[address.toLowerCase()] = {pubKey: pubKey, index: i, name: members.rowData(i, "name")}
        }

        const myAddress = utilsModel.derivedAnUserAddress(profileModel.profile.pubKey).toLowerCase()
        ethersChannel.postMessage(request, (users) => {
                                      data.clear();
                                      users.forEach(function (userAddress) {
                                          userAddress = userAddress.toLowerCase()
                                          if (userAddress === myAddress) {
                                              // it's me
                                              return
                                          } else if (!pubKeyByAddress[userAddress]) {
                                              data.append({
                                                              address: userAddress
                                                          });
                                          } else {
                                              data.append({
                                                              address: userAddress,
                                                              name: members.rowData(pubKeyByAddress[userAddress].index, "name"),
                                                              pubKey: pubKeyByAddress[userAddress].pubKey,
                                                              identicon: members.rowData(pubKeyByAddress[userAddress].index, "identicon")
                                                          });
                                          }


                                      })
                                  });
    }

    onOpened: {
        resetSelectedMembers();
    }

    height: userListMode ? 500 : 350
    width: 500

    header: Item {
        height: children[0].height
        width: parent.width


        StatusLetterIdenticon {
            id: letterIdenticon
            width: 36
            height: 36
            anchors.top: parent.top
            color: chatsModel.activeChannel.color
            chatName: chatsModel.activeChannel.name
        }

        StyledTextEdit {
            id: groupName
            text: qsTr("Manage moderators")
            anchors.verticalCenter: letterIdenticon.verticalCenter
            anchors.left: letterIdenticon.right
            anchors.leftMargin: Style.current.smallPadding
            font.bold: true
            font.pixelSize: 14
            readOnly: true
            wrapMode: Text.WordWrap
        }
    }


    Item {
        id: userList
        visible: userListMode === true
        anchors.fill: parent

        SearchBox {
            id: searchBox
            iconWidth: 17
            iconHeight: 17
            customHeight: 44
            fontPixelSize: 15
        }

        Rectangle {
            id: noUsersRect
            width: 320
            visible: data.count == 0
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
            StyledText {
                id: noUsersText
                text: qsTr("There are no moderators currently in this channel")
                color: Style.current.textColor
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ScrollView {
            visible: data.count > 0
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.top: searchBox.bottom
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: groupMembers.contentHeight > groupMembers.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                anchors.fill: parent
                model: ListModel {
                    id: data
                }
                spacing: 0
                clip: true
                id: groupMembers
                delegate: Contact {
                    isVisible: searchBox.text == "" || model.name.includes(searchBox.text) || model.address.includes(searchBox.text)
                    showCheckbox: true
                    pubKey: model.address // we put the address instead because we don't care about the pubkey
                    isUser: false
                    name: model.name ? model.name : model.address
                    address: model.address
                    identicon: model.identicon || ""
                    onItemChecked: function(address, itemChecked){
                        var idx = selectedAddresses.indexOf(address)
                        if(itemChecked){
                            if(idx === -1){
                                selectedAddresses.push(address)
                            }
                        } else {
                            if(idx > -1){
                                selectedAddresses.splice(idx, 1);
                            }
                        }
                    }
                }
            }
        }
    }


    Column {
        visible: userListMode === false
        spacing: Style.current.padding
        width: parent.width

        Item {
            height: addOperatorField.height
            width: parent.width

            Input {
                id: addOperatorField
                label: qsTr("Add a moderator")
                placeholderText: qsTr("Moderator address")
                anchors.right: btnAddOperator.left
                anchors.rightMargin: Style.current.halfPadding
            }

            StyledButton {
                id: btnAddOperator
                label: qsTr("Add")
                anchors.right: parent.right
                anchors.bottom: addOperatorField.bottom
                onClicked: {
                    console.log('ADD ME', addOperatorField.text)
                }
            }
        }

        Item {
            height: removeOperatorField.height
            width: parent.width

            Input {
                id: removeOperatorField
                label: qsTr("Remove a Moderator")
                placeholderText: qsTr("Moderator address")
                anchors.right: btnRemoveOperator.left
                anchors.rightMargin: Style.current.halfPadding
            }

            StyledButton {
                id: btnRemoveOperator
                label: qsTr("Remove")
                anchors.right: parent.right
                anchors.bottom: removeOperatorField.bottom
                onClicked: {
                    console.log('REMOVE ME', removeOperatorField.text)
                }
            }
        }
    }

    footer: Item {
        width: parent.width

        StyledButton {
            label: userListMode ? qsTr("See the form") : qsTr("See the moderator list")
            onClicked: userListMode = !userListMode
        }

        StyledButton {
            visible: userListMode
            anchors.right: parent.right
            label: qsTr("Remove checked moderators")
            onClicked: {
                if (selectedAddresses.length === 0) {
                    return
                }

                // TODO add function to remove all at once or loop
                console.log('Remove those')
            }
        }
    }
}

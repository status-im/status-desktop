import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../../../../shared/controls"
import "../../../../shared/popups"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    property var store
    property string activeMailserver: ""

    Connections {
        target: root.store.mailservers
        onActiveMailserverChanged: (activeMailserver) => {
            root.activeMailserver = root.store.getMailserverName(activeMailserver)
        }
    }

    Item {
        width: profileContainer.profileContentWidth
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Component {
            id: mailserversList
            
            // TODO: Replace with StatusQ component
            StatusRadioButton {
                id: rbSetMailsever
                text: name
                checked: name === activeMailserver
                onClicked: {
                    if (checked) {
                        root.store.setMailserver(name)
                    }
                }
            }
        }

        Item {
            id: addMailserver
            width: parent.width
            height: addButton.height
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 24

            StatusFlatRoundButton {
                id: addButton
                icon.name: "add"
                anchors.verticalCenter: parent.verticalCenter
            }

                    
            StatusBaseText {
                id: usernameText
                //% "Add mailserver"
                text: qsTrId("add-mailserver")
                color: Theme.palette.primaryColor1
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: addMailserverPopup.open()
            }

            // TODO: replace with StatusModal
            ModalPopup {
                id: addMailserverPopup
                //% "Add mailserver"
                title: qsTrId("add-mailserver")

                property string nameValidationError: ""
                property string enodeValidationError: ""
                
                function validate() {
                    nameValidationError = ""
                    enodeValidationError = ""
                    
                    if (nameInput.text === "") {
                        //% "You need to enter a name"
                        nameValidationError = qsTrId("you-need-to-enter-a-name")
                    }

                    if (enodeInput.text === "") {
                        //% "You need to enter the enode address"
                        enodeValidationError = qsTrId("you-need-to-enter-the-enode-address")
                    }
                    return !nameValidationError && !enodeValidationError
                }

                onOpened: {
                    nameInput.text = "";
                    enodeInput.text = "";
        
                    nameValidationError = "";
                    enodeValidationError = "";
                }

                footer: StatusButton {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    //% "Save"
                    text: qsTrId("save")
                    anchors.bottom: parent.bottom
                    enabled: nameInput.text !== "" && enodeInput.text !== ""
                    onClicked: {
                        if (!addMailserverPopup.validate()) {
                            return;
                        }
                        root.store.saveMailserver(nameInput.text, enodeInput.text)
                        addMailserverPopup.close()
                    }
                }

                Input {
                    id: nameInput
                    //% "Name"
                    label: qsTrId("name")
                    //% "Specify a name"
                    placeholderText: qsTrId("specify-name")
                    validationError: addMailserverPopup.nameValidationError
                }

                Input {
                    id: enodeInput
                    //% "History node address"
                    label: qsTrId("history-node-address")
                    //% "enode://{enode-id}:{password}@{ip-address}:{port-number}"
                    placeholderText: qsTrId("enode----enode-id---password---ip-address---port-number-")
                    validationError: addMailserverPopup.enodeValidationError
                    anchors.top: nameInput.bottom
                    anchors.topMargin: Style.current.bigPadding
                }

            }
        }

        StatusBaseText {
            id: switchLbl
            //% "Automatic mailserver selection"
            text: qsTrId("automatic-mailserver-selection")
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: addMailserver.bottom
            anchors.topMargin: 24
        }

        StatusSwitch {
            id: automaticSelectionSwitch
            checked: root.store.automaticMailserverSelection
            onCheckedChanged: root.store.enableAutomaticMailserverSelection(checked)
            anchors.top: addMailserver.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: switchLbl.right
            anchors.leftMargin: Style.current.padding
        }

        StatusBaseText {
            //% "..."
            text: qsTr("Active mailserver: %1").arg(activeMailserver) || qsTrId("---")
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: switchLbl.bottom
            anchors.topMargin: 24
            visible: automaticSelectionSwitch.checked
        }

        ListView {
            id: mailServersListView
            anchors.topMargin: 20
            anchors.top: automaticSelectionSwitch.bottom
            anchors.bottom: parent.bottom
            model: root.store.mailserversList
            delegate: mailserversList
            visible: !automaticSelectionSwitch.checked
        }
    }
}

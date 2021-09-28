import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


import utils 1.0
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

Item {
    id: root
    width: parent.width
    height: 120

    property bool deleteButtonVisible
    property string accountName: accountNameInput.text
    property bool nameInputValid: accountNameInput.valid
    property string accountAddress: model.address
    property string emoji: "" //TODO implement emoji selection
    signal deleteClicked()

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusInput {
                id: accountNameInput
                anchors.fill: parent
                input.implicitHeight: 56
                input.placeholderText: qsTrId("enter-an-account-name...")
                label: "Ledger" //TODO replace with derivation path, for now use Ledger
                secondaryLabel: address.replace(address.substring(6, (address.length-4)), "...")
                validators: [StatusMinLengthValidator { minLength: 1 }]
                onTextChanged: {
                    errorMessage = (accountNameInput.text === "") ?
                                qsTrId("you-need-to-enter-an-account-name") : ""
                }
            }
        }
        Item {
            //emoji placeholder
            Layout.preferredWidth: 80
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 8
            StatusBaseText {
                id: inputLabel
                text: "Emoji"
                font.weight: Font.Medium
                font.pixelSize: 13
                color: Style.current.textColor
            }
            Rectangle {
                width: parent.width
                height: 56
                anchors.top: inputLabel.bottom
                anchors.topMargin: 7
                radius: 10
                color: "pink"
                opacity: 0.6
            }
        }

        Control {
            id: deleteButton
            Layout.preferredWidth: 50
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignBottom
            visible: root.deleteButtonVisible
            background: Item {
                anchors.fill: deleteButton
                StatusIcon {
                    anchors.centerIn: parent
                    color: Theme.palette.baseColor1
                    icon: "delete"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.deleteClicked();
                    }
                }
            }
        }
    }
}

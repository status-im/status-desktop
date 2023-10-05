import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0

import "../stores"

StatusModal {
    id: root

    required property var accountsModule
    required property string keyUid
    required property string name
    required property var accounts

    headerSettings.title: qsTr("Rename keypair")
    focus: visible
    padding: Style.current.padding

    QtObject {
        id: d

        property bool entryValid: false

        function updateValidity() {
            d.entryValid = nameInput.valid
            if (!d.entryValid) {
                return
            }
            d.entryValid = d.entryValid && nameInput.text !== root.name
            if (!d.entryValid) {
                nameInput.errorMessageCmp.text = qsTr("Same name")
                nameInput.valid = false
                return
            }
            d.entryValid = d.entryValid && !root.accountsModule.keypairNameExists(nameInput.text)
            if (!d.entryValid) {
                nameInput.errorMessageCmp.text = qsTr("Keypair name already in use")
                nameInput.valid = false
            }
        }

        function confirm() {
            if (d.entryValid) {
                root.accountsModule.renameKeypair(root.keyUid, nameInput.text)
                root.close()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.current.halfPadding

        StatusInput {
            id: nameInput
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 120
            topPadding: 8
            bottomPadding: 8
            label: qsTr("Keypair name")
            charLimit: Constants.keypair.nameLengthMax
            validators: Constants.validators.keypairName
            input.clearable: true
            input.rightPadding: 16
            text: root.name

            onTextChanged: {
                d.updateValidity()
            }
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: Style.current.padding
            text: qsTr("Accounts derived from this keypair")
            font.pixelSize: Style.current.primaryTextFontSize
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 60
            color: "transparent"
            radius: 8
            border.width: 1
            border.color: Theme.palette.baseColor2

            StatusScrollView {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: contentHeight
                padding: 0
                leftPadding: 16
                rightPadding: 16

                Row {
                    spacing: 10
                    Repeater {
                        model: root.accounts
                        delegate: StatusListItemTag {
                            bgColor: Utils.getColorForId(model.account.colorId)
                            height: Style.current.bigPadding
                            bgRadius: 6
                            tagClickable: false
                            closeButtonVisible: false
                            asset {
                                emoji: model.account.emoji
                                emojiSize: Emoji.size.verySmall
                                isLetterIdenticon: !!model.account.emoji
                                name: model.account.icon
                                color: Theme.palette.indirectColor1
                                width: 16
                                height: 16
                            }
                            title: model.account.name
                            titleText.font.pixelSize: 12
                            titleText.color: Theme.palette.indirectColor1
                        }
                    }
                }
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            text: qsTr("Cancel")
            type: StatusBaseButton.Type.Normal
            onClicked: {
                root.close()
            }
        },
        StatusButton {
            text: qsTr("Save changes")
            enabled: d.entryValid
            focus: true
            Keys.onReturnPressed: function(event) {
                d.confirm()
            }
            onClicked: {
                d.confirm()
            }
        }
    ]
}

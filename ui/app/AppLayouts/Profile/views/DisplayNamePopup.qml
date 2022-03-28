import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1

StatusModal {
    id: root
    property var profileStore

    width: 420
    height: 250
    closePolicy: Popup.NoAutoClose
    header.title: qsTr("Edit")
    contentItem: Item {
        StatusInput {
            id: displayNameInput
            width: parent.width - Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            input.placeholderText: qsTr("Display Name")
            input.text: root.profileStore.displayName
            validators: [
                StatusMinLengthValidator {
                    minLength: 5
                    errorMessage: qsTr("Username must be at least 5 characters")
                },
                StatusRegularExpressionValidator {
                    regularExpression: /^[a-zA-Z0-9\-_]+$/
                    errorMessage: qsTr("Only letters, numbers, underscores and hyphens allowed")
                },
                // TODO: Create `StatusMaxLengthValidator` in StatusQ
                StatusValidator {
                    name: "maxLengthValidator"
                    validate: function (t) { return displayNameInput.input.text.length <= 24 }
                    errorMessage: qsTr("24 character username limit")
                },
                StatusValidator {
                    name: "endsWith-ethValidator"
                    validate: function (t) { return !displayNameInput.input.text.endsWith("-eth") }
                    errorMessage: qsTr("Usernames ending with '-eth' are not allowed")
                },
                StatusValidator {
                    name: "endsWith_ethValidator"
                    validate: function (t) { return !displayNameInput.input.text.endsWith("_eth") }
                    errorMessage: qsTr("Usernames ending with '_eth' are not allowed")
                },
                StatusValidator {
                    name: "endsWith.ethValidator"
                    validate: function (t) { return !displayNameInput.input.text.endsWith(".eth") }
                    errorMessage: qsTr("Usernames ending with '.eth' are not allowed")
                },
                StatusValidator {
                    name: "isAliasValidator"
                    validate: function (t) { return !globalUtils.isAlias(displayNameInput.input.text) }
                    errorMessage: qsTr("Sorry, the name you have chosen is not allowed, try picking another username")
                }
            ]
        }
    }

    rightButtons: [
        StatusButton {
            id: doneBtn
            text: qsTr("Ok")
            enabled: displayNameInput.valid
            onClicked: {
                root.profileStore.setDisplayName(displayNameInput.input.text)
                root.close()
            }
        }
    ]

    onOpened: { displayNameInput.input.forceActiveFocus(Qt.MouseFocusReason) }
}


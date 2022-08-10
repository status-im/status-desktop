import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.controls.chat 1.0
import "../panels"
import "../popups"
import "../stores"


import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        d.resetLogin()
    }

    onStateChanged: {
        pinInputField.statesInitialization()
        pinInputField.forceFocus()
    }

    QtObject {
        id: d
        property bool loading: false

        readonly property string stateLoginRegularUser: "regularUserLogin"
        readonly property string stateLoginKeycardUser: "keycardUserLogin"

        property int index: 0
        property variant images : [
            Style.svg("keycard/card0@2x"),
            Style.svg("keycard/card1@2x"),
            Style.svg("keycard/card2@2x"),
            Style.svg("keycard/card3@2x")
        ]

        property int remainingAttempts: parseInt(root.startupStore.startupModuleInst.keycardData, 10)
        onRemainingAttemptsChanged: {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }

        function doLogin(password) {
            if (d.loading || password.length === 0)
                return

            d.loading = true
            txtPassword.textField.clear()
            root.startupStore.setPassword(password)
            root.startupStore.doPrimaryAction()
        }

        function doKeycardLogin(pin) {
            if (d.loading || pin.length === 0)
                return

            d.loading = true
            root.startupStore.setPin(pin)
            root.startupStore.doPrimaryAction()
        }

        function resetLogin() {
            if(localAccountSettings.storeToKeychainValue !== Constants.keychain.storedValue.store)
            {
                if (!root.startupStore.selectedLoginAccount.keycardCreatedAccount){
                    txtPassword.visible = true
                    txtPassword.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }
    }

    Timer {
        interval: 400
        running: root.state === d.stateLoginKeycardUser ||
                 root.state === Constants.startupState.loginKeycardInsertKeycard ||
                 root.state === Constants.startupState.loginKeycardReadingKeycard
        repeat: true
        onTriggered: {
            d.index++
            image.source = d.images[d.index % d.images.length]
        }
    }

    Connections{
        target: root.startupStore.startupModuleInst

        onObtainingPasswordError: {
            if (root.startupStore.selectedLoginAccount.keycardCreatedAccount) {
                root.startupStore.doPrimaryAction() // in this case, switch to enter pin state
            }

            if (errorType === Constants.keychain.errorType.authentication) {
                // We are notifying user only about keychain errors.
                return
            }

            obtainingPasswordErrorNotification.confirmationText = errorDescription
            obtainingPasswordErrorNotification.open()
        }

        onObtainingPasswordSuccess: {
            if(localAccountSettings.storeToKeychainValue !== Constants.keychain.storedValue.store)
                return

            if (root.startupStore.selectedLoginAccount.keycardCreatedAccount) {
                d.doKeycardLogin(password)
            }
            else {
                d.doLogin(password)
            }
        }

        onAccountLoginError: {
            if (error) {
                if (!root.startupStore.selectedLoginAccount.keycardCreatedAccount) {
                    // SQLITE_NOTADB: "file is not a database"
                    if (error === "file is not a database") {
                        txtPassword.validationError = qsTr("Password incorrect")
                    } else {
                        txtPassword.validationError = qsTr("Login failed: %1").arg(error.toUpperCase())
                    }
                    d.loading = false
                    txtPassword.textField.forceActiveFocus()
                }
            }
        }
    }

    ConfirmationDialog {
        id: obtainingPasswordErrorNotification
        height: 270
        confirmButtonLabel: qsTr("Ok")

        onConfirmButtonClicked: {
            close()
        }

        onClosed: {
            txtPassword.visible = true
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.bigPadding

        Image {
            id: image
            Layout.alignment: Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            mipmap: true
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: Constants.onboarding.titleFontSize
            color: Theme.palette.directColor1
        }

        Item {
            id: userInfo
            height: userImage.height
            width: 318
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.xlPadding

            UserImage {
                id: userImage
                image: root.startupStore.selectedLoginAccount.thumbnailImage
                name: root.startupStore.selectedLoginAccount.username
                colorId: root.startupStore.selectedLoginAccount.colorId
                colorHash: root.startupStore.selectedLoginAccount.colorHash
                anchors.left: parent.left
                imageHeight: Constants.onboarding.userImageHeight
                imageWidth: Constants.onboarding.userImageWidth
            }

            StatusBaseText {
                id: usernameText
                text: root.startupStore.selectedLoginAccount.username
                font.pixelSize: 17
                anchors.left: userImage.right
                anchors.right: root.startupStore.selectedLoginAccount.keycardCreatedAccount?
                                   keycardIcon.left : changeAccountBtn.left
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: userImage.verticalCenter
                color: Theme.palette.directColor1
                elide: Text.ElideRight
            }

            StatusIcon {
                id: keycardIcon
                visible: root.startupStore.selectedLoginAccount.keycardCreatedAccount
                anchors.right: changeAccountBtn.left
                anchors.verticalCenter: userImage.verticalCenter
                icon: "keycard"
                height: Style.current.padding
                color: Theme.palette.baseColor1
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: changeAccountBtn.clicked(mouse)
            }

            StatusFlatRoundButton {
                id: changeAccountBtn
                objectName: "loginChangeAccountButton"
                icon.name: "chevron-down"
                icon.rotation: accountsPopup.opened ? 180 : 0
                type: StatusFlatRoundButton.Type.Tertiary
                width: 24
                height: 24
                anchors.verticalCenter: usernameText.verticalCenter
                anchors.right: parent.right

                onClicked: {
                    if (accountsPopup.opened) {
                        accountsPopup.close()
                    } else {
                        accountsPopup.popup(
                                    userInfo,
                                    (userInfo.width - accountsPopup.width) / 2,
                                    userInfo.height + Style.current.halfPadding)
                    }
                }
            }

            StatusPopupMenu {
                id: accountsPopup
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                width: parent.width + Style.current.bigPadding
                dim: false
                Repeater {
                    id: accounts
                    model: root.startupStore.startupModuleInst.loginAccountsModel
                    delegate: AccountMenuItemPanel {
                        label: model.username
                        image: model.thumbnailImage
                        colorId: model.colorId
                        colorHash: model.colorHash
                        keycardCreatedAccount: model.keycardCreatedAccount
                        onClicked: {
                            root.startupStore.setSelectedLoginAccountByIndex(index)
                            d.resetLogin()
                            accountsPopup.close()
                        }
                    }
                }

                AccountMenuItemPanel {
                    label: qsTr("Add new user")
                    onClicked: {
                        accountsPopup.close()
                        root.startupStore.doSecondaryAction()
                    }
                }

                AccountMenuItemPanel {
                    label: qsTr("Add existing Status user")
                    iconSettings.name: "wallet"
                    onClicked: {
                        accountsPopup.close()
                        root.startupStore.doTertiaryAction()
                    }
                }
            }
        }

        Item {
            id: passwordSection
            Layout.fillWidth: true
            Layout.preferredHeight: txtPassword.height
            Layout.alignment: Qt.AlignHCenter

            Input {
                id: txtPassword
                textField.objectName: "loginPasswordInput"
                validationErrorObjectName: "loginPassworkInputValidationErrorText"
                width: 318
                height: 70
                enabled: !d.loading
                validationErrorAlignment: Text.AlignHCenter
                validationErrorTopMargin: 10
                placeholderText: d.loading ?
                                     qsTr("Connecting...") :
                                     qsTr("Password")
                textField.echoMode: TextInput.Password
                Keys.onReturnPressed: {
                    d.doLogin(textField.text)
                }
                onTextEdited: {
                    validationError = "";
                    d.loading = false
                }
            }

            StatusRoundButton {
                id: submitBtn
                width: 40
                height: 40
                type: StatusRoundButton.Type.Secondary
                icon.name: "arrow-right"
                opacity: (d.loading || txtPassword.text.length > 0) ? 1 : 0
                anchors.left: txtPassword.right
                anchors.leftMargin: (d.loading || txtPassword.text.length > 0) ? Style.current.padding : Style.current.smallPadding
                state: d.loading ? "pending" : "default"
                onClicked: {
                    d.doLogin(txtPassword.textField.text)
                }

                // https://www.figma.com/file/BTS422M9AkvWjfRrXED3WC/%F0%9F%91%8B-Onboarding%E2%8E%9CDesktop?node-id=6%3A0
                Behavior on opacity {
                    OpacityAnimator {
                        from: 0.5
                        duration: 200
                    }
                }
                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Column {
            id: pinSection
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.current.padding

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Constants.keycard.general.fontSize2
                wrapMode: Text.WordWrap
                text: qsTr("Enter Keycard PIN")
            }

            StatusPinInput {
                id: pinInputField
                anchors.horizontalCenter: parent.horizontalCenter
                validator: StatusIntValidator{bottom: 0; top: 999999;}
                pinLen: Constants.keycard.general.keycardPinLength
                enabled: !d.loading

                onPinInputChanged: {
                    if(pinInput.length == 0)
                        return
                    root.startupStore.setPin(pinInput)
                    root.startupStore.doPrimaryAction()
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize3
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize3
            wrapMode: Text.WordWrap
        }

        StatusButton {
            id: button
            Layout.alignment: Qt.AlignHCenter
            focus: true
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }

        StatusBaseText {
            id: link
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.primaryColor1
            font.pixelSize: Constants.keycard.general.fontSize2
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    root.startupStore.doPrimaryAction()
                }
            }
        }
    }

    states: [
        State {
            name: d.stateLoginRegularUser
            when: !root.startupStore.selectedLoginAccount.keycardCreatedAccount
            PropertyChanges {
                target: image
                source: Style.png("status-logo")
                Layout.preferredHeight: 128
                Layout.preferredWidth: 128
            }
            PropertyChanges {
                target: title
                text: qsTr("Welcome back")
            }
            PropertyChanges {
                target: passwordSection
                visible: true
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: ""
                visible: false
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: d.stateLoginKeycardUser
            when: root.startupStore.selectedLoginAccount.keycardCreatedAccount &&
                  root.startupStore.currentStartupState.stateType === Constants.startupState.login
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Plug in Keycard reader...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardInsertKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardInsertKeycard
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Insert your Keycard...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardReadingKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardReadingKeycard
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Reading Keycard...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardEnterPin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardEnterPin
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: true
            }
            PropertyChanges {
                target: info
                text: ""
                visible: false
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardWrongKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardWrongKeycard
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-wrong3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Wrong Keycard!\nThe card inserted is not linked to your profile.")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("Insert another Keycard")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardWrongPin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardWrongPin
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-wrong3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: true
            }
            PropertyChanges {
                target: info
                text: qsTr("PIN incorrect")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                text: qsTr("%n attempt(s) remaining", "", d.remainingAttempts)
                color: d.remainingAttempts === 1?
                           Theme.palette.dangerColor1 :
                           Theme.palette.baseColor1
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardMaxPinRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPinRetriesReached
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Keycard locked")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover your Keycard")
                visible: true
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardMaxPukRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPukRetriesReached
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Keycard locked")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover with seed phrase")
                visible: true
            }
            PropertyChanges {
                target: link
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.startupState.loginKeycardEmpty
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardEmpty
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-wrong3@2x")
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
            }
            PropertyChanges {
                target: title
                text: ""
                visible: false
            }
            PropertyChanges {
                target: passwordSection
                visible: false
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("The card inserted is empty")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: ""
                visible: false
            }
            PropertyChanges {
                target: link
                text: qsTr("Generate keys for a new Keycard")
                visible: true
            }
        }
    ]
}

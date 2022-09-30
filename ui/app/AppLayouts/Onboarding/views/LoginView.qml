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

import shared.popups.keycard.helpers 1.0

import SortFilterProxyModel 0.2

import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.controls.chat 1.0
import "../panels"
import "../popups"

import AppLayouts.Onboarding.stores 1.0

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        d.resetLogin()
    }

    onStateChanged: {
        d.loading = false
        if(state === Constants.startupState.loginKeycardPinVerified) {
            pinInputField.setPin("123456") // we are free to set fake pin in this case
            pinInputField.enabled = false
        } else {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    Timer {
        id: timer
        interval: 1000
        running: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardRecognizedKeycard ||
                 root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardPinVerified
        onTriggered: {
            root.startupStore.doPrimaryAction()
        }
    }

    QtObject {
        id: d
        property bool loading: false

        readonly property string stateLoginRegularUser: "regularUserLogin"
        readonly property string stateLoginKeycardUser: "keycardUserLogin"

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

    Connections{
        target: root.startupStore.startupModuleInst

        onObtainingPasswordError: {
            if (errorType === Constants.keychain.errorType.authentication) {
                // We are notifying user only about keychain errors.
                return
            }

            image.source = Style.png("keycard/biometrics-fail")
            info.icon = ""
            info.color = Theme.palette.dangerColor1
            info.text = qsTr("Fingerprint not recognized")

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
        height: Constants.keycard.general.loginHeight
        spacing: Style.current.bigPadding

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.general.imageHeight
            Layout.preferredWidth: Constants.keycard.general.imageWidth

            onAnimationCompleted: {
                if (root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardInsertedKeycard ||
                        root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardReadingKeycard) {
                    root.startupStore.doPrimaryAction()
                }
            }
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
            Layout.preferredHeight: userImage.height
            Layout.preferredWidth: 318
            Layout.alignment: Qt.AlignHCenter
            enabled: root.startupStore.currentStartupState.stateType !== Constants.startupState.loginKeycardReadingKeycard &&
                     root.startupStore.currentStartupState.stateType !== Constants.startupState.loginKeycardRecognizedKeycard &&
                     root.startupStore.currentStartupState.stateType !== Constants.startupState.loginKeycardPinVerified

            UserImage {
                id: userImage
                objectName: "loginViewUserImage"
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
                objectName: "currentUserNameLabel"
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
                        accountsPopup.topMargin =
                                Qt.binding(function(){
                                    return userInfo.mapToItem(
                                                root,
                                                root.height,
                                                userInfo.height + Style.current.halfPadding).y
                                    })
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

                SortFilterProxyModel {
                    id: proxyModel
                    sourceModel: root.startupStore.startupModuleInst.loginAccountsModel
                    filters: ValueFilter {
                        roleName: "keyUid"
                        value: root.startupStore.selectedLoginAccount.keyUid
                        inverted: true
                    }
                }

                Column {
                    width: parent.width

                    Repeater {
                        model: proxyModel

                        delegate: AccountMenuItemPanel {
                            label: model.username
                            image: model.thumbnailImage
                            colorId: model.colorId
                            colorHash: model.colorHash
                            keycardCreatedAccount: model.keycardCreatedAccount
                            onClicked: {
                                d.resetLogin()
                                accountsPopup.close()
                                const realIndex = proxyModel.mapToSource(index)
                                root.startupStore.setSelectedLoginAccountByIndex(realIndex)
                            }
                        }
                    }

                    AccountMenuItemPanel {
                        label: qsTr("Add new user")
                        asset.name: "add"
                        onClicked: {
                            accountsPopup.close()
                            root.startupStore.doTertiaryAction()
                        }
                    }

                    AccountMenuItemPanel {
                        label: qsTr("Add existing Status user")
                        asset.name: "wallet"
                        onClicked: {
                            accountsPopup.close()
                            root.startupStore.doQuaternaryAction()
                        }
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

            property alias text: pinText.text

            StatusBaseText {
                id: pinText
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
                    if (root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardPinVerified)
                        return
                    if (root.state !== Constants.startupState.loginKeycardWrongPin) {
                        image.source = Style.png("keycard/enter-pin-%1".arg(pinInput.length))
                    }
                    if(pinInput.length == 0)
                        return
                    root.startupStore.setPin(pinInput)
                    root.startupStore.doPrimaryAction()
                }
            }
        }

        Row {
            id: info
            Layout.alignment: Qt.AlignCenter
            spacing: Style.current.halfPadding

            property alias text: infoTxt.text
            property alias font: infoTxt.font
            property alias color: infoTxt.color
            property alias icon: infoIcon.icon

            StatusIcon {
                id: infoIcon
                visible: icon !== ""
                width: Style.current.padding
                height: Style.current.padding
                color: Theme.palette.baseColor1
            }
            StatusLoadingIndicator {
                id: loading
                visible: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardReadingKeycard
            }
            StatusBaseText {
                id: infoTxt
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Constants.keycard.general.fontSize3
                wrapMode: Text.WordWrap
            }
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
                    root.startupStore.doSecondaryAction()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: d.stateLoginRegularUser
            when: !root.startupStore.selectedLoginAccount.keycardCreatedAccount &&
                  root.startupStore.currentStartupState.stateType === Constants.startupState.login
            PropertyChanges {
                target: image
                source: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store?
                            Style.png("keycard/biometrics-success") : Style.png("status-logo")
                pattern: ""
                Layout.preferredHeight: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store?
                                            Constants.keycard.general.imageHeight :
                                            Constants.keycard.general.loginStatusLogoHeight
                Layout.preferredWidth: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store?
                                           Constants.keycard.general.imageWidth :
                                           Constants.keycard.general.loginStatusLogoWidth
            }
            PropertyChanges {
                target: title
                text: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store? "" : qsTr("Welcome back")
                visible: localAccountSettings.storeToKeychainValue !== Constants.keychain.storedValue.store
            }
            PropertyChanges {
                target: passwordSection
                visible: localAccountSettings.storeToKeychainValue !== Constants.keychain.storedValue.store
            }
            PropertyChanges {
                target: pinSection
                visible: false
            }
            PropertyChanges {
                target: info
                text: qsTr("Waiting for TouchID...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: "touch-id"
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
                text: qsTr("Use password instead")
                visible: true
            }
        },
        State {
            name: d.stateLoginKeycardUser
            when: root.startupStore.selectedLoginAccount.keycardCreatedAccount &&
                  root.startupStore.currentStartupState.stateType === Constants.startupState.login
            PropertyChanges {
                target: image
                source: Style.png("keycard/biometrics-success")
                pattern: ""
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
                text: qsTr("Waiting for TouchID...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: "touch-id"
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
                text: qsTr("Use PIN instead")
                visible: true
            }
        },
        State {
            name: Constants.startupState.loginPlugin
            when: root.startupStore.selectedLoginAccount.keycardCreatedAccount &&
                  root.startupStore.currentStartupState.stateType === Constants.startupState.loginPlugin
            PropertyChanges {
                target: image
                source: Style.png("keycard/empty-reader")
                pattern: ""
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
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
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
                pattern: "keycard/card_insert/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 16
                duration: 1000
                loops: 1
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
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
            }
            PropertyChanges {
                target: message
                visible: root.startupStore.startupModuleInst.keycardData & Constants.predefinedKeycardData.wronglyInsertedCard
                text: qsTr("Check the card, it might be wrongly inserted")
                font.pixelSize: Constants.keycard.general.fontSize3
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
            name: Constants.startupState.loginKeycardInsertedKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardInsertedKeycard
            PropertyChanges {
                target: image
                pattern: "keycard/card_inserted/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 29
                duration: 1000
                loops: 1
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
                text: qsTr("Keycard inserted...")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
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
                pattern: "keycard/warning/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 55
                duration: 3000
                loops: 1
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
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
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
            name: Constants.startupState.loginKeycardRecognizedKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardRecognizedKeycard
            PropertyChanges {
                target: image
                pattern: "keycard/success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 29
                duration: 1300
                loops: 1
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
                text: qsTr("Keycard recognized")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: "checkmark"
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
            name: Constants.startupState.loginKeycardEnterPassword
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardEnterPassword
            PropertyChanges {
                target: image
                source: Style.png("status-logo")
                pattern: ""
                Layout.preferredHeight: Constants.keycard.general.loginStatusLogoHeight
                Layout.preferredWidth: Constants.keycard.general.loginStatusLogoWidth
            }
            PropertyChanges {
                target: title
                text: qsTr("Welcome back")
                visible: true
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
                visible: true
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
                source: Style.png("keycard/card-empty")
                pattern: ""
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
                text: qsTr("Enter Keycard PIN")
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
            name: Constants.startupState.loginKeycardPinVerified
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardPinVerified
            PropertyChanges {
                target: image
                pattern: "keycard/strong_success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 20
                duration: 1300
                loops: 1
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
                text: qsTr("PIN Verified")
            }
            PropertyChanges {
                target: info
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
            name: Constants.startupState.loginKeycardWrongKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardWrongKeycard
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
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
                height: Constants.keycard.general.loginInfoHeight2
                icon: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("Insert proper Keycard")
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
                source: Style.png("keycard/plain-error")
                pattern: ""
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
                text: qsTr("Enter Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("PIN incorrect")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
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
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPinRetriesReached ||
                  root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPukRetriesReached ||
                  root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPairingSlotsReached
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
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
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
            PropertyChanges {
                target: button
                text: qsTr("Unlock Keycard")
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
                source: Style.png("keycard/card-empty")
                pattern: ""
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
                text: qsTr("The card inserted is empty (has no profile linked).")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
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
        },
        State {
            name: Constants.startupState.loginNotKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.loginNotKeycard
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
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
                text: qsTr("This is not a Keycard")
                visible: true
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
                height: Constants.keycard.general.loginInfoHeight1
                icon: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("The card inserted is not a recognised Keycard,\nplease remove and try and again")
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
        }
    ]
}

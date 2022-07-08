import QtQuick 2.12
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import "../stores"

ColumnLayout {

    property string text: privateKey.text
    property bool valid: privateKey.valid

    function resetMe() {
        _internal.errorString = ""
        privateKey.text = ""
        privateKey.reset()
    }

    function validateMe()  {
        if (privateKey.text === "") {
            _internal.errorString = qsTr("You need to enter a private key")
        } else if (!Utils.isPrivateKey(privateKey.text)) {
            _internal.errorString = qsTr("Enter a valid private key (64 characters hexadecimal string)")
        } else {
            _internal.errorString = ""
        }
        return _internal.errorString === ""
    }

    QtObject {
        id: _internal
        property int privateKeyCharLimit: 66
        property string errorString: ""
        property bool accountAreadyAddedError: Utils.accountAlreadyExistsError(RootStore.derivedAddressesError)
    }

    spacing: 24

    StatusInput {
        id: privateKey

        label: qsTr("Private key")
        charLimit: _internal.privateKeyCharLimit
        input.multiline: true
        input.minimumHeight: 80
        input.maximumHeight: 108
        input.placeholderText: qsTr("Paste the contents of your private key")
        errorMessage: _internal.errorString
        validators: [
            StatusMinLengthValidator {
                minLength: 1
                errorMessage: qsTr("You need to enter a private key")
            },
            StatusValidator {
                property var validate: function (value) {
                    return Utils.isPrivateKey(value)
                }
                errorMessage: qsTr("Enter a valid private key (64 characters hexadecimal string)")
            }
        ]
        onTextChanged: {
            if(valid) {
                RootStore.getDerivedAddressForPrivateKey(text)
            }
        }

        onVisibleChanged:  {
            if(visible)
                privateKey.input.edit.forceActiveFocus();
        }
    }

    ColumnLayout {
        spacing: 8

        StatusBaseText {
            id: inputLabel
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            text: qsTr("Public address")
            font.pixelSize: 15
        }

        StatusListItem {
            id: derivedAddress
            property string address:  RootStore.derivedAddressesList.count > 0 ?  RootStore.getDerivedAddressData(0) : "---"
            property bool hasActivity: RootStore.derivedAddressesList.count > 0 ?  RootStore.getDerivedAddressHasActivityData(0) : false
            Layout.alignment: Qt.AlignHCenter
            icon.background.color: "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            type: _internal.accountAreadyAddedError ? StatusListItem.Type.Danger : StatusListItem.Type.Primary
            statusListItemSubTitle.color: derivedAddress.hasActivity ?  Theme.palette.primaryColor1 : Theme.palette.baseColor1
            title: _internal.accountAreadyAddedError ? qsTr("Account already added") : RootStore.derivedAddressesLoading ? qsTr("Pending") : derivedAddress.address
            subTitle: RootStore.derivedAddressesLoading || _internal.accountAreadyAddedError ?  "" : derivedAddress.hasActivity ? qsTr("Has Activity"): qsTr("No Activity")
            sensor.enabled: false
        }
    }
}



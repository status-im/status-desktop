import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import "../stores"
import "../panels"

ColumnLayout {
    id: advancedSection

    property int addAccountType: SelectGeneratedAccount.AddAccountType.GenerateNew
    property string derivedFromAddress: ""
    property string mnemonicText: ""
    property alias privateKey: importPrivateKeyPanel.text
    property string path: ""
    property string pathSubFix: ""
    property string completePath: path + "/" + pathSubFix
    property alias watchAddress: addressInput.text
    property bool isValid: addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase ? importSeedPhrasePanel.isValid :
                           addAccountType === SelectGeneratedAccount.AddAccountType.ImportPrivateKey ? (importPrivateKeyPanel.text !== "" && importPrivateKeyPanel.valid) :
                           addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly ? (addressInput.text !== "" && addressInput.valid) : true

    signal calculateDerivedPath()
    signal enterPressed()

    function reset() {
        //reset selectGeneratedAccount
        selectGeneratedAccount.resetMe()

        // reset privateKey
        importPrivateKeyPanel.resetMe()

        // reset importSeedPhrasePanel
        importSeedPhrasePanel.reset()

        // reset derivation path
        derivationPathsPanel.reset()

        // reset derviedAccountsList
        derivedAddressesPanel.reset()

        // reset watch only address input
        addressInput.text = ""
        addressInput.reset()
    }

    function validate() {
        if(addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase) {
            // validate mnemonic
            return importSeedPhrasePanel.validate()
        }
        else if(addAccountType === SelectGeneratedAccount.AddAccountType.ImportPrivateKey) {
            // validate privateKey
            return importPrivateKeyPanel.validateMe()
        }
        else if(addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly) {
            return addressInput.valid
        }

        return true
    }

    onPathChanged:  {
        if(addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase) {
            if(importSeedPhrasePanel.isValid) {
                calculateDerivedPath()
            }
        }
        else {
            calculateDerivedPath()
        }
    }

    onDerivedFromAddressChanged:  {
        // reset derviedAccountsList
        derivedAddressesPanel.reset()

        if(addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase) {
            if(importSeedPhrasePanel.isValid) {
                calculateDerivedPath()
            }
        }
        else {
            calculateDerivedPath()
        }
    }

    spacing: Style.current.padding

    SelectGeneratedAccount {
        id: selectGeneratedAccount
        Component.onCompleted: {
            advancedSection.addAccountType = Qt.binding(function() {return addAccountType})
            advancedSection.derivedFromAddress = Qt.binding(function() {return derivedFromAddress})
        }
    }

    ImportPrivateKeyPanel {
        id: importPrivateKeyPanel
        visible: advancedSection.addAccountType === SelectGeneratedAccount.AddAccountType.ImportPrivateKey && advancedSection.visible
    }

    ImportSeedPhrasePanel {
        id: importSeedPhrasePanel
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: visible ? importSeedPhrasePanel.preferredHeight: 0
        Layout.leftMargin: (Style.current.halfPadding/4)
        visible: advancedSection.addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase && advancedSection.visible
        onMnemonicStringChanged: {
            advancedSection.mnemonicText = mnemonicString
            if(isValid) {
                calculateDerivedPath()
            }
        }
        onEnterPressed: advancedSection.enterPressed()
    }

    StatusInput {
        id: addressInput
        visible: advancedSection.addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly && advancedSection.visible
        input.placeholderText: qsTr("Enter address...")
        label: qsTr("Account address")
        validators: [
            StatusAddressValidator {
                errorMessage: qsTr("This needs to be a valid address (starting with 0x)")
            },
            StatusMinLengthValidator {
                errorMessage: qsTr("You need to enter an address")
                minLength: 1
            }
        ]
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.rightMargin: 2
        spacing: Style.current.bigPadding
        visible: advancedSection.addAccountType !== SelectGeneratedAccount.AddAccountType.ImportPrivateKey &&
                 advancedSection.addAccountType !== SelectGeneratedAccount.AddAccountType.WatchOnly
        DerivationPathsPanel {
            id: derivationPathsPanel
            Layout.preferredWidth: ((parent.width - (Style.current.bigPadding/2))/2)
            Layout.alignment: Qt.AlignTop
            Component.onCompleted: advancedSection.path = Qt.binding(function() { return derivationPathsPanel.path})
        }
        DerivedAddressesPanel {
            id: derivedAddressesPanel
            Layout.preferredWidth: ((parent.width - (Style.current.bigPadding/2))/2)
            Layout.alignment: Qt.AlignTop
            Component.onCompleted: advancedSection.pathSubFix = Qt.binding(function() { return derivedAddressesPanel.pathSubFix})
        }
    }
}


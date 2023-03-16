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

    property int addAccountType: Constants.AddAccountType.GenerateNew
    property string selectedKeyUid: RootStore.defaultSelectedKeyUid
    property bool selectedKeyUidMigratedToKeycard: RootStore.defaultSelectedKeyUidMigratedToKeycard
    property string selectedAddress: ""
    property bool selectedAddressAvailable: true
    property string enterPasswordIcon: ""
    property string derivedFromAddress: ""
    property string mnemonicText: ""
    property alias privateKey: importPrivateKeyPanel.text
    property string path: ""
    property string pathSubFix: ""
    property string completePath: path + "/" + pathSubFix
    property alias watchAddress: addressInput.text
    property bool isValid: addAccountType === Constants.AddAccountType.ImportSeedPhrase ? importSeedPhrasePanel.isValid :
                           addAccountType === Constants.AddAccountType.ImportPrivateKey ? (importPrivateKeyPanel.text !== "" && importPrivateKeyPanel.valid) :
                           addAccountType === Constants.AddAccountType.WatchOnly ? (addressInput.text !== "" && addressInput.valid) : true

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
        if(addAccountType === Constants.AddAccountType.ImportSeedPhrase) {
            // validate mnemonic
            return importSeedPhrasePanel.validate()
        }
        else if(addAccountType === Constants.AddAccountType.ImportPrivateKey) {
            // validate privateKey
            return importPrivateKeyPanel.validateMe()
        }
        else if(addAccountType === Constants.AddAccountType.WatchOnly) {
            return addressInput.valid
        }

        return true
    }

    onPathChanged:  {
        if(addAccountType === Constants.AddAccountType.ImportSeedPhrase) {
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

        if(addAccountType === Constants.AddAccountType.ImportSeedPhrase) {
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
            advancedSection.selectedKeyUid = Qt.binding(function() {return selectedKeyUid})
            advancedSection.selectedKeyUidMigratedToKeycard = Qt.binding(function() {return selectedKeyUidMigratedToKeycard})
        }
    }

    ImportPrivateKeyPanel {
        id: importPrivateKeyPanel
        visible: advancedSection.addAccountType === Constants.AddAccountType.ImportPrivateKey && advancedSection.visible
    }

    ImportSeedPhrasePanel {
        id: importSeedPhrasePanel
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: visible ? importSeedPhrasePanel.preferredHeight: 0
        Layout.leftMargin: (Style.current.halfPadding/4)
        visible: advancedSection.addAccountType === Constants.AddAccountType.ImportSeedPhrase && advancedSection.visible
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
        visible: advancedSection.addAccountType === Constants.AddAccountType.WatchOnly && advancedSection.visible
        placeholderText: qsTr("Enter address...")
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
        Layout.preferredWidth: parent.width
        Layout.rightMargin: 2
        spacing: Style.current.bigPadding
        visible: advancedSection.addAccountType !== Constants.AddAccountType.ImportPrivateKey &&
                 advancedSection.addAccountType !== Constants.AddAccountType.WatchOnly

        readonly property int itemWidth: (advancedSection.width - Style.current.bigPadding) * 0.5

        DerivationPathsPanel {
            id: derivationPathsPanel
            Layout.preferredWidth: parent.itemWidth
            Layout.alignment: Qt.AlignTop
            Component.onCompleted: advancedSection.path = Qt.binding(function() { return derivationPathsPanel.path})
        }
        DerivedAddressesPanel {
            id: derivedAddressesPanel
            Layout.preferredWidth: parent.itemWidth
            Layout.alignment: Qt.AlignTop

            selectedAccountType: advancedSection.addAccountType
            selectedKeyUid: advancedSection.selectedKeyUid
            selectedKeyUidMigratedToKeycard: advancedSection.selectedKeyUidMigratedToKeycard
            selectedPath: advancedSection.path

            Component.onCompleted: {
                advancedSection.selectedAddress = Qt.binding(function() { return derivedAddressesPanel.selectedAddress})
                advancedSection.selectedAddressAvailable = Qt.binding(function() { return derivedAddressesPanel.selectedAddressAvailable})
                advancedSection.pathSubFix = Qt.binding(function() { return derivedAddressesPanel.pathSubFix})
            }
        }
    }
}


import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import "../stores"

ColumnLayout {
    id: advancedSection

    property alias privateKey: privateKey.text
    property int addAccountType: AdvancedAddAccountView.AddAccountType.GenerateNew
    property string mnemonicText: getSeedPhraseString()
    property string errorString: ""
    property bool isValid: addAccountType === AdvancedAddAccountView.AddAccountType.ImportSeedPhrase ? grid.isValid :
                           addAccountType === AdvancedAddAccountView.AddAccountType.ImportPrivateKey ? (privateKey.text !== "" && privateKey.valid) : true

    enum AddAccountType {
        GenerateNew,
        ImportSeedPhrase,
        ImportPrivateKey
    }

    function reset() {
        mnemonicText = ""
        errorString = ""
        select.currentIndex = 0
        addAccountType = AdvancedAddAccountView.AddAccountType.GenerateNew
        privateKey.text = ""
        privateKey.reset()
        for(var i = 0; i < grid.model; i++) {
            if(grid.itemAtIndex(i)) {
                grid.itemAtIndex(i).textEdit.text =  ""
                grid.itemAtIndex(i).textEdit.reset()
            }
        }
    }

    function validate() {
        errorString = "";
        if(addAccountType == AdvancedAddAccountView.AddAccountType.ImportSeedPhrase) {
            mnemonicText = getSeedPhraseString()

            if (!Utils.isMnemonic(mnemonicText)) {
                //% "Invalid seed phrase"
                errorString = qsTrId("custom-seed-phrase")
            } else {
                errorString = onboardingModule.validateMnemonic(mnemonicText)
                const regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
                if (regex.test(errorString)) {
                    //% "Invalid seed phrase"
                    errorString = qsTrId("custom-seed-phrase") + '. ' +
                            //% "This seed phrase doesn't match our supported dictionary. Check for misspelled words."
                            qsTrId("custom-seed-phrase-text-1")
                }
            }
            return errorString === ""
        }
        else if(addAccountType == AdvancedAddAccountView.AddAccountType.ImportPrivateKey) {
            if (privateKey.text === "") {
                //% "You need to enter a private key"
                errorString = qsTrId("you-need-to-enter-a-private-key")
            } else if (!Utils.isPrivateKey(privateKey.text)) {
                //% "Enter a valid private key (64 characters hexadecimal string)"
                errorString = qsTrId("enter-a-valid-private-key-(64-characters-hexadecimal-string)")
            } else {
                errorString = ""
            }
            return errorString === ""
        }
        return true
    }

    function getSeedPhraseString() {
        var seedPhrase = ""
        for(var i = 0; i < grid.model; i++) {
            seedPhrase += grid.itemAtIndex(i).text + " "
        }
        return seedPhrase
    }

    QtObject {
        id: _internal
        property int seedPhraseInputHeight: 44
        property int seedPhraseInputWidth: 220
    }

    spacing: Style.current.padding

    StatusSelect {
        id: select
        //% "Origin"
        label: qsTr("Origin")
        Layout.margins: Style.current.padding
        property int currentIndex: 0
        selectedItemComponent: StatusListItem {
            id: selectedItem
            icon.background.color: "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            tagsDelegate: StatusListItemTag {
                color: model.color
                height: Style.current.bigPadding
                radius: 6
                closeButtonVisible: false
                icon.emoji: model.emoji
                icon.emojiSize: Emoji.size.verySmall
                icon.isLetterIdenticon: true
                title: model.name
                titleText.font.pixelSize: 12
                titleText.color: Theme.palette.indirectColor1
            }
        }
        model: ListModel {
            Component.onCompleted: {
                //% "Default"
                append({"name": qsTr("Default"), "iconName": "status", "accountsModel": RootStore.generatedAccounts, "enabled": true})
                //% "Add new"
                append({"name": qsTr("Add new"), "iconName": "", "enabled": false})
                //% "Import new Seed Phrase"
                append({"name": qsTr("Import new Seed Phrase"), "iconName": "seed-phrase", "enabled": true})
                //% "Import new Private Key"
                append({"name": qsTr("Import new Private Key"), "iconName": "password", "enabled": true})
                selectedItem.title = Qt.binding(function() {return get(select.currentIndex).name})
                selectedItem.icon.name = Qt.binding(function() {return get(select.currentIndex).iconName})
                selectedItem.tagsModel = Qt.binding(function() {return get(select.currentIndex).accountsModel})
            }
        }
        selectMenu.delegate: StatusListItem {
            id: defaultListItem
            title: model.name
            icon.name: model.iconName
            tagsModel : model.accountsModel
            enabled: model.enabled
            icon.background.color: "transparent"
            icon.color: model.accountsModel ? Theme.palette.primaryColor1 : Theme.palette.directColor5
            tagsDelegate: StatusListItemTag {
                color: model.color
                height: 24
                radius: 6
                closeButtonVisible: false
                icon.emoji: model.emoji
                icon.emojiSize: Emoji.size.verySmall
                icon.isLetterIdenticon: true
                title: model.name
                titleText.font.pixelSize: 12
                titleText.color: Theme.palette.indirectColor1
            }
            onClicked: {
                advancedSection.addAccountType = (index === 2) ? AdvancedAddAccountView.AddAccountType.ImportSeedPhrase :
                                                                 (index === 3) ? AdvancedAddAccountView.AddAccountType.ImportPrivateKey :
                                                                                 AdvancedAddAccountView.AddAccountType.GenerateNew
                select.currentIndex = index
                select.selectMenu.close()
            }
        }
    }

    StatusInput {
        id: privateKey
        //% "Private key"
        label: qsTrId("private-key")
        charLimit: 66
        input.multiline: true
        input.minimumHeight: 80
        input.maximumHeight: 108
        //% "Paste the contents of your private key"
        input.placeholderText: qsTrId("paste-the-contents-of-your-private-key")
        visible: advancedSection.addAccountType === AdvancedAddAccountView.AddAccountType.ImportPrivateKey && advancedSection.visible
        errorMessage: advancedSection.errorString
        validators: [
            StatusMinLengthValidator {
                minLength: 1
                //% "You need to enter a private key"
                errorMessage: qsTrId("you-need-to-enter-a-private-key")
            },
            StatusValidator {
                property var validate: function (value) {
                    return Utils.isPrivateKey(value)
                }
                //% "Enter a valid private key (64 characters hexadecimal string)"
                errorMessage: qsTrId("enter-a-valid-private-key-(64-characters-hexadecimal-string)")
            }
        ]
        onVisibleChanged:  {
            if(visible)
                privateKey.input.edit.forceActiveFocus();
        }
    }

    GridView {
        id: grid
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: visible ? (cellHeight * model/2) + footerItem.height: 0
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        visible: advancedSection.addAccountType === AdvancedAddAccountView.AddAccountType.ImportSeedPhrase && advancedSection.visible
        cellHeight: _internal.seedPhraseInputHeight + Style.current.halfPadding
        cellWidth: _internal.seedPhraseInputWidth + Style.current.halfPadding
        model: 12
        interactive: false
        property bool isValid: checkIsValid()
        function checkIsValid() {
            var valid = model > 0 ? true: false
            for(var i = 0; i < model; i++) {
                if(grid.itemAtIndex(i))
                    valid &= grid.itemAtIndex(i).isValid
            }
            return valid
        }

        onVisibleChanged:  {
            if(visible)
                grid.itemAtIndex(0).textEdit.input.edit.forceActiveFocus();
        }

        // To-do Alex has introduced a model for bip39 dictonary, need to use it once its available
        //  https://github.com/status-im/status-desktop/pull/5058
        delegate: StatusSeedPhraseInput {
            id: statusSeedInput
            width: _internal.seedPhraseInputWidth
            height: _internal.seedPhraseInputHeight
            textEdit.errorMessageCmp.visible: false
            textEdit.input.anchors.topMargin: 11
            leftComponentText: index + 1
            property bool isValid: !!text
            onIsValidChanged:  {
                grid.isValid = grid.checkIsValid()
            }
            onTextChanged: {
                if (text !== "") {
                    grid.currentIndex = index;
                }
            }
            // To-do Alex has introduced a model for bip39 dictonary, need to use it once its available
            //  https://github.com/status-im/status-desktop/pull/5058
            //            onDoneInsertingWord: {
            //                advancedSection.mnemonicText += (index === 0) ? word : (" " + word);
            //                for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
            //                    if (parseInt(grid.itemAtIndex(i).leftComponentText) === (parseInt(leftComponentText)+1)) {
            //                        grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
            //                    }
            //                }
            //            }
            onEditClicked: {
                grid.currentIndex = index;
                grid.itemAtIndex(index).textEdit.input.edit.forceActiveFocus();
            }
            onKeyPressed: {
                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
                    for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                        if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)+1) <= grid.count ? (parseInt(leftComponentText)+1) : grid.count)) {
                            grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                            textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit;
                        }
                    }
                } else if (event.key === Qt.Key_Left) {
                    for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                        if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)-1) >= 0 ? (parseInt(leftComponentText)-1) : 0)) {
                            grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                        }
                    }
                } else if (event.key === Qt.Key_Down) {
                    grid.itemAtIndex((index+1 < grid.count) ? (index+1) : (grid.count-1)).textEdit.input.edit.forceActiveFocus();
                } else if (event.key === Qt.Key_Up) {
                    grid.itemAtIndex((index-1 >= 0) ? (index-1) : 0).textEdit.input.edit.forceActiveFocus();
                }
            }
            textEdit.validators: [
                StatusMinLengthValidator {
                    errorMessage: qsTr("Enter a valid word")
                    minLength: 3
                }
            ]
        }
        footer: Item {
            width: grid.width - Style.current.padding
            height: button.height + errorMessage.height + 16*2
            StatusBaseText {
                id: errorMessage

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding

                height: visible ? implicitHeight : 0
                visible: !!text
                text: errorString

                font.pixelSize: 12
                color: Theme.palette.dangerColor1
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            StatusButton {
                id: button
                visible: false
                anchors.top: errorMessage.bottom
                anchors.topMargin: Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter
                //% "Use 24 word seed phrase"
                text: grid.model === 12 ? qsTr("Use 24 word seed phrase"):
                                          qsTr("Use 12 word seed phrase")
                onClicked: grid.model = grid.model === 12 ? 24 : 12
            }
        }
    }


    RowLayout {
        Layout.margins: Style.current.padding
        Layout.preferredWidth: parent.width
        spacing: Style.current.bigPadding
        StatusSelect {
            Layout.preferredWidth: 213
            //% "Origin"
            label: qsTr("Derivation Path")
            selectedItemComponent: StatusListItem {
                width: parent.width
                icon.background.color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                title: "Default"
                subTitle: "m/44’/61’/0’/1"
                enabled: false
            }
            enabled: false
        }
        StatusSelect {
            Layout.preferredWidth: 213
            //% "Origin"
            label: qsTr("Account")
            width: parent.width
            enabled: false
            selectedItemComponent: StatusListItem {
                icon.background.color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                title: "0x1234...abcd"
                subTitle: "No activity"
                enabled: false
            }
        }
    }
}


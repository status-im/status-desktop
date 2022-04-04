import QtQuick 2.12
import QtQml.Models 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import "../stores"

StatusSelect {
    id: selectAccountType

    property int addAccountType
    property string derivedFromAddress: ""

    enum AddAccountType {
        GenerateNew,
        ImportSeedPhrase,
        ImportPrivateKey,
        WatchOnly
    }

    function resetMe() {
        _internal.getGeneratedAccountsModel()
        addAccountType = SelectGeneratedAccount.AddAccountType.GenerateNew
    }

    Connections {
        target: RootStore.generatedAccountsViewModel
        onModelReset: {
            _internal.delegateModel.model = RootStore.generatedAccountsViewModel
            _internal.getGeneratedAccountsModel()
        }
    }

    QtObject {
        id: _internal
        property string importSeedPhraseString : qsTr("Import new Seed Phrase")
        property string importPrivateKeyString : qsTr("Generate from Private key")
        property string addWatchOnlyAccountString : qsTr("Add a watch-only address")

        property var delegateModel: DelegateModel {
            model: RootStore.generatedAccountsViewModel
            onModelUpdated: {
                _internal.getGeneratedAccountsModel()
            }
        }
        property ListModel generatedAccountsModel: ListModel{}

        function getGeneratedAccountsModel() {
            if(generatedAccountsModel) {
                generatedAccountsModel.clear()
                for (var row = 0; row < _internal.delegateModel.model.count; row++) {
                    if (_internal.delegateModel.items.count > 0) {
                        var item = _internal.delegateModel.items.get(row).model;
                        generatedAccountsModel.append({"name": item.name, "iconName": item.iconName, "generatedModel": item.generatedModel, "derivedfrom": item.derivedfrom, "isHeader": false})
                        if (row === 0 && _internal.delegateModel.model.count > 1) {
                            generatedAccountsModel.append({"name": qsTr("Imported"), "iconName": "", "derivedfrom": "", "isHeader": true})
                        }
                    }
                }
                generatedAccountsModel.append({"name": qsTr("Add new"), "iconName": "", "derivedfrom": "", "isHeader": true})
                generatedAccountsModel.append({"name": _internal.importSeedPhraseString, "iconName": "seed-phrase", "derivedfrom": "", "isHeader": false})
                generatedAccountsModel.append({"name": _internal.importPrivateKeyString, "iconName": "password", "derivedfrom": "", "isHeader": false})
                generatedAccountsModel.append({"name": _internal.addWatchOnlyAccountString, "iconName": "show", "derivedfrom": "", "isHeader": false})
            }
        }
    }

    label: qsTr("Origin")
    model: _internal.generatedAccountsModel
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
    selectMenu.delegate: StatusListItem {
        id: defaultListItem
        title: model.name
        icon.name: model.iconName
        tagsModel : model.generatedModel
        enabled: !model.isHeader
        icon.background.color: "transparent"
        icon.color: model.generatedModel ? Theme.palette.primaryColor1 : Theme.palette.directColor5
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
            selectAccountType.addAccountType = (model.name === _internal.importSeedPhraseString) ? SelectGeneratedAccount.AddAccountType.ImportSeedPhrase :
                                             (model.name === _internal.importPrivateKeyString) ? SelectGeneratedAccount.AddAccountType.ImportPrivateKey :
                                             (model.name === _internal.addWatchOnlyAccountString) ? SelectGeneratedAccount.AddAccountType.WatchOnly :
                                             SelectGeneratedAccount.AddAccountType.GenerateNew
            selectedItem.title = model.name
            selectedItem.icon.name = model.iconName
            selectedItem.tagsModel = model.generatedModel
            selectedItem.enabled =  !model.isHeader

            selectAccountType.derivedFromAddress = model.derivedfrom
            selectMenu.close()
        }
        Component.onCompleted: {
            if(index === 0) {
                selectedItem.title = model.name
                selectedItem.icon.name = model.iconName
                selectedItem.tagsModel = model.generatedModel
                selectedItem.enabled =  !model.isHeader
                selectAccountType.derivedFromAddress = model.derivedfrom
            }
        }
    }
}



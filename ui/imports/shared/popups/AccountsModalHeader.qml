import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Controls.Validators 0.1

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"
import "../views"

StatusFloatingButtonsSelector {
    id: root

    property var selectedAccount
    // Expected signature: function(newAccount)
    property var changeSelectedAccount: function(){}
    property bool showAllWalletTypes: false

    repeater.objectName: "accountsListFloatingHeader"

    signal updatedSelectedAccount(var account)

    delegate: Rectangle {
        width: button.width
        height: button.height
        radius: 8
        color: Theme.palette.baseColor3
        StatusButton {
            id: button
            size: StatusBaseButton.Size.Tiny
            implicitHeight: 32
            leftPadding: 4
            text: name
            objectName: name
            asset.emoji: !!emoji ? emoji: ""
            icon.name: !emoji ? "filled-account": ""
            normalColor: "transparent"
            hoverColor: Theme.palette.statusFloatingButtonHighlight
            highlighted: index === root.currentIndex
            onClicked: {
                changeSelectedAccount(model)
                root.currentIndex = index
            }
            Component.onCompleted: {
                // on model reset, set the selected account to the one that was previously selected
                if(root.selectedAccount === null) {
                    if(root.currentIndex === index) {
                        changeSelectedAccount(model)
                    }
                }
                else {
                    // if the selectedAccount is watch only then select 0th item
                    if(index === 0 && !!root.selectedAccount && root.selectedAccount.walletType === Constants.watchWalletType) {
                        changeSelectedAccount(model)
                        root.currentIndex = index
                    }
                }
            }
        }
    }
    popupMenuDelegate: StatusListItem {
        implicitWidth: 272
        title: name
        subTitle: LocaleUtils.currencyAmountToLocaleString(currencyBalance)
        asset.emoji: !!emoji ? emoji: ""
        asset.color: model.color
        asset.name: !emoji ? "filled-account": ""
        asset.letterSize: 14
        asset.isLetterIdenticon: !!model.emoji
        asset.bgColor: Theme.palette.indirectColor1
        onClicked: {
            changeSelectedAccount(model)
            root.selectItem(index)
        }
    }
}


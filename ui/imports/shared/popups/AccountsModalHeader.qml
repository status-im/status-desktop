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
    // Expected signature: function(newAccount, newIndex)
    property var changeSelectedAccount: function(){}
    property bool showAllWalletTypes: false

    repeater.objectName: "accountsListFloatingHeader"

    signal updatedSelectedAccount(var account)

    QtObject {
        id: d
        property var firstModelData: null

        function isWalletTypeAccepted(walletType, index) {
            return (root.showAllWalletTypes || walletType !== Constants.watchWalletType)
        }
    }

    delegate: Rectangle {
        width: button.width
        height: button.height
        radius: 8
        visible: root.visibleIndices.includes(index) && d.isWalletTypeAccepted(walletType, index)
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
                changeSelectedAccount(model, index)
                root.currentIndex = index
            }
            Component.onCompleted: {
                // On startup make the preseected wallet in the floating menu,
                // and if the selectedAccount is watch only then select 0th item
                if(index === 0) {
                    d.firstModelData = model
                }

                if(name !== root.selectedAccount.name) {
                    return
                }

                if(name === root.selectedAccount.name) {
                    if(d.isWalletTypeAccepted(walletType, index)) {
                        // If the selected index wont be displayed, added it to the visible indices
                        if(index > 2) {
                            visibleIndices = [0, 1, index]
                        }
                        root.currentIndex = index
                    }
                    else {
                        changeSelectedAccount(root.selectedAccount, 0)
                        root.currentIndex = 0
                    }
                }
            }
        }
    }
    popupMenuDelegate: StatusListItem {
        implicitWidth: 272
        title: name
        subTitle: currencyBalance
        asset.emoji: !!emoji ? emoji: ""
        asset.color: model.color
        asset.name: !emoji ? "filled-account": ""
        asset.letterSize: 14
        asset.isLetterIdenticon: !!model.emoji
        asset.bgColor: Theme.palette.indirectColor1
        onClicked: {
            changeSelectedAccount(model, index)
            root.itemSelected(index)
        }
        visible: !root.visibleIndices.includes(index) && d.isWalletTypeAccepted(walletType, index)
    }
}


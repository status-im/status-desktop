import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"
import "../panels"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    Component.onCompleted: {
        if (root.store.addAccountModule.selectedColor === "") {
            colorSelection.selectedColorIndex = Math.floor(Math.random() * colorSelection.model.length)
        }
        else {
            let ind = d.evaluateColorIndex(root.store.addAccountModule.selectedColor)
            colorSelection.selectedColorIndex = ind
        }

        if (root.store.addAccountModule.selectedEmoji === "") {
            root.store.addAccountModule.selectedEmoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
        }

        accountName.text = root.store.addAccountModule.accountName
        accountName.input.edit.forceActiveFocus()
    }

    QtObject {
        id: d

        function evaluateColorIndex(color) {
            for (let i = 0; i < Constants.preDefinedWalletAccountColors.length; i++) {
                if(Constants.preDefinedWalletAccountColors[i] === color) {
                    return i
                }
            }
            return 0
        }
    }

    Connections {
        target: root.store.emojiPopup

        function onEmojiSelected (emojiText, atCursor) {
            root.store.addAccountModule.selectedEmoji = emojiText
        }
    }

    Component {
        id: spacer
        Rectangle {
            color: Theme.palette.baseColor4
        }
    }

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 0

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            sourceComponent: spacer
        }

        Column {
            Layout.fillWidth: true
            spacing: Style.current.padding
            topPadding: Style.current.padding
            bottomPadding: Style.current.padding

            StatusInput {
                id: accountName
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Enter an account name...")
                label: qsTr("Name")
                text: root.store.addAccountModule.accountName
                input.isIconSelectable: true
                input.leftPadding: Style.current.padding
                input.asset.color: root.store.addAccountModule.selectedColor
                input.asset.emoji: root.store.addAccountModule.selectedEmoji
                onIconClicked: {
                    if (!root.store.emojiPopup) {
                        return
                    }
                    let inputCoords = accountName.mapToItem(appMain, 0, 0)
                    root.store.emojiPopup.open()
                    root.store.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall
                    root.store.emojiPopup.x = inputCoords.x
                    root.store.emojiPopup.y = inputCoords.y + accountName.height + Style.current.halfPadding
                }

                onTextChanged: {
                    root.store.addAccountModule.accountName = text
                }

                onKeyPressed: {
                    root.store.submitAddAccount(event)
                }
            }

            StatusColorSelectorGrid {
                id: colorSelection
                anchors.horizontalCenter: parent.horizontalCenter
                model: Constants.preDefinedWalletAccountColors
                title.color: Theme.palette.directColor1
                title.font.pixelSize: Constants.addAccountPopup.labelFontSize1
                title.text: qsTr("Colour")
                selectedColorIndex: -1

                onSelectedColorChanged: {
                    root.store.addAccountModule.selectedColor = selectedColor
                }
            }

            SelectOrigin {
                anchors.horizontalCenter: parent.horizontalCenter

                userProfilePublicKey: root.store.userProfilePublicKey
                originModel: root.store.originModel
                selectedOrigin: root.store.selectedOrigin

                onOriginSelected: {
                    if (keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddNewMasterKey) {
                        root.store.currentState.doSecondaryAction()
                        return
                    }
                    root.store.changeSelectedOrigin(keyUid)
                }
            }

            WatchOnlyAddressSection {
                width: parent.width - 2 * Style.current.padding
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Style.current.padding
                visible: root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.unknown &&
                         root.store.selectedOrigin.keyUid === Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc

                store: root.store

                onVisibleChanged: {
                    reset()
                }
            }
        }

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            sourceComponent: spacer
        }

        DerivationPathSection {
            id: derivationPathSection
            Layout.fillWidth: true
            visible: root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.profile ||
                     root.store.selectedOrigin.pairType === Constants.addAccountPopup.keyPairType.seedImport
            store: root.store
        }

        Loader {
            Layout.preferredHeight: Style.current.padding
            Layout.fillWidth: true
            visible: derivationPathSection.visible
            sourceComponent: spacer
        }
    }
}

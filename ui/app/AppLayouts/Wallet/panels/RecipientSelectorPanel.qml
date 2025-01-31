import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.views 1.0

import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import shared.panels 1.0 as SharedPanels

import utils 1.0

Rectangle {
    id: root

    /**
        Expected roles (for both models):

        address     [string] - unique wallet address
        name        [string] (optional)
        color       [string] (optional)
        colorId     [string] (optional)
        emoji       [string] (optional)
        ens         [string] (optional)
    */
    required property var recipientsModel
    required property var recipientsFilterModel

    /** Search pattern in recipient view input **/
    readonly property string searchPattern: recipientInputLoader.searchPattern

    /** Currently viewed tab is empty **/
    readonly property bool emptyListVisible: emptyListText.visible && !selectedRecipientAddress

    /** Currently selected recipient tab  **/
    readonly property alias selectedRecipientType: d.selectedRecipientType
    /** Selected recipient address. It is input and output property **/
    property alias selectedRecipientAddress: recipientInputLoader.selectedRecipientAddress

    /** Can selector be interacted **/
    property bool interactive: true

    /** Request ens address to be resolved **/
    signal resolveENS(string ensName, string uuid)

    function ensNameResolved(resolvedPubKey, resolvedAddress, uuid) {
        recipientInputLoader.ensNameResolved(resolvedPubKey, resolvedAddress, uuid)
    }

    implicitHeight: childrenRect.height + (emptyListText.visible ? Theme.bigPadding : Theme.halfPadding / 2)
    color: Theme.palette.indirectColor1
    radius: 8

    onSearchPatternChanged: {
        if (d.highlightedIndex > -1)
            d.highlightedIndex = 0
    }

    QtObject {
        id: d

        readonly property bool searchInProgress: !!root.searchPattern && root.recipientsFilterModel.ModelCount.count > 0
        property int highlightedIndex: 0
        property int selectedRecipientType: Constants.RecipientAddressObjectType.RecentsAddress

        function handleKeyPressOnSearch(event) {
            if (!event || !d.searchInProgress || highlightedIndex === -1)
                return

            switch(event.key) {
                case Qt.Key_Return:
                case Qt.Key_Enter: {
                    const address = StatusQUtils.ModelUtils.get(root.recipientsFilterModel, d.highlightedIndex, "address")
                    recipientInputLoader.selectedRecipientAddress = address
                    event.accepted = true
                    return
                }
                case Qt.Key_Down: {
                    if (d.highlightedIndex < root.recipientsFilterModel.ModelCount.count - 1) {
                        d.highlightedIndex++
                    } else {
                        d.highlightedIndex = 0
                    }

                    event.accepted = true
                    return
                }
                case Qt.Key_Up: {
                    if (d.highlightedIndex > 0) {
                        d.highlightedIndex--
                    } else {
                        d.highlightedIndex = root.recipientsFilterModel.ModelCount.count - 1
                    }

                    event.accepted = true
                    return
                }
                default:
                    return
            }
        }
    }

    ColumnLayout {
        id: layout

        width: parent.width
        spacing: 0

        RecipientView {
            id: recipientInputLoader

            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.topMargin: Theme.smallPadding / 2

            interactive: root.interactive

            model: root.recipientsFilterModel

            onResolveENS: root.resolveENS(ensName, uuid)
            onKeyPressed: (event) => d.handleKeyPressOnSearch(event)
        }

        SharedPanels.Separator {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: Theme.palette.baseColor2
            visible: !root.selectedRecipientAddress
        }

        StatusTabBar {
            id: recipientTypeTabBar

            objectName: "recipientTypeTabBar"

            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.topMargin: 12

            StatusTabButton {
                leftPadding: Theme.padding
                width: implicitWidth
                objectName: "recentAddressesTab"
                text: qsTr("Recent")
                onClicked: d.selectedRecipientType = Constants.RecipientAddressObjectType.RecentsAddress
            }
            StatusTabButton {
                width: implicitWidth
                objectName: "savedAddressesTab"
                text: qsTr("Saved")
                onClicked: d.selectedRecipientType = Constants.RecipientAddressObjectType.SavedAddress
            }
            StatusTabButton {
                width: implicitWidth
                objectName: "myAccountsTab"
                text: qsTr("My Accounts")
                onClicked: d.selectedRecipientType = Constants.RecipientAddressObjectType.Account
            }

            visible: !root.selectedRecipientAddress && !d.searchInProgress
        }

        SharedPanels.Separator {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: -Theme.halfPadding
            color: Theme.palette.baseColor2
            visible: recipientTypeTabBar.visible
        }

        StatusBaseText {
            id: emptyListText
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Theme.bigPadding
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.baseColor1
            text: {
                switch(root.selectedRecipientType) {
                    case Constants.RecipientAddressObjectType.RecentsAddress:
                        return qsTr("Recently used addresses will appear here")
                    case Constants.RecipientAddressObjectType.SavedAddress:
                        return qsTr("Your saved addresses will appear here")
                    case Constants.RecipientAddressObjectType.Account:
                        return qsTr("Add another account to send tokens between them")
                    default:
                        return ""
                }
            }

            visible: !root.selectedRecipientAddress && !d.searchInProgress && root.recipientsModel.ModelCount.count === 0 && !!text
        }

        Repeater {
            id: walletList
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: Theme.halfPadding / 2
            Layout.fillWidth: true

            model: root.selectedRecipientAddress ? null : (d.searchInProgress ? root.recipientsFilterModel : root.recipientsModel)

            delegate: RecipientViewDelegate {
                required property var model

                Layout.fillWidth: true
                Layout.preferredHeight: 64
                Layout.leftMargin: Theme.halfPadding / 2
                Layout.rightMargin: Theme.halfPadding / 2

                name: model.name ?? ""
                address: model.address
                emoji: model.emoji ?? ""
                walletColor: model.color ?? ""
                walletColorId: model.colorId ?? ""
                ens: model.ens ?? ""

                highlighted: d.searchInProgress && model.index === d.highlightedIndex
                sensor.onContainsMouseChanged: d.highlightedIndex = sensor.containsMouse ? -1 : 0

                onClicked: recipientInputLoader.selectedRecipientAddress = address
            }
        }
    }
}

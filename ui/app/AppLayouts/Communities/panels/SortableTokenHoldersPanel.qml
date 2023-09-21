import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0

Control {
    id: root

    // Expected roles: name, walletAddress, imageSource, NumberOfMessages, amount
    property var model

    property string tokenName
    property bool showRemotelyDestructMenuItem: true
    property alias isAirdropEnabled: infoBoxPanel.buttonEnabled

    readonly property alias sortBy: holdersList.sortBy
    readonly property alias sorting: holdersList.sortOrder

    readonly property bool empty: countCheckHelper.count === 0

    signal viewProfileRequested(string contactId)
    signal viewMessagesRequested(string contactId)
    signal airdropRequested(string address)
    signal remoteDestructRequested(string name, string address)
    signal kickRequested(string name, string contactId, string address)
    signal banRequested(string name, string contactId, string address)

    signal generalAirdropRequested

    Instantiator {
        id: countCheckHelper

        model: root.model
        delegate: QtObject {}
    }

    TokenHoldersProxyModel {
        id: proxyModel

        sourceModel: root.model || null
        searchText: searcher.text

        sortBy: holdersList.sortBy
        sortOrder: holdersList.sortOrder ? Qt.DescendingOrder : Qt.AscendingOrder
    }

    QtObject {
        id: d

        readonly property int red2Color: 4
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StatusBaseText {
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1

            text: qsTr("%1 token holders").arg(root.tokenName)
        }

        SearchBox {
            id: searcher

            Layout.fillWidth: true
            Layout.topMargin: 12

            visible: !root.empty

            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36 // by design
            maximumHeight: minimumHeight

            placeholderText: qsTr("Search hodlers")
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: 12

            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1

            visible: searcher.text.length > 0

            text: (searcher.text.length > 0 && proxyModel.count > 0)
                  ? qsTr("Search results") : qsTr("No hodlers found")
        }

        StatusInfoBoxPanel {
            id: infoBoxPanel

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            visible: root.empty
            title: qsTr("No hodlers just yet")
            text: qsTr("You can Airdrop tokens to deserving Community members or to give individuals token-based permissions.")
            buttonText: qsTr("Airdrop")

            onClicked: root.generalAirdropRequested()
        }

        SortableTokenHoldersList {
            id: holdersList

            visible: !root.empty && proxyModel.count > 0

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.topMargin: 20

            model: proxyModel

            onClicked: {
                if (mouse.button !== Qt.RightButton)
                    return

                const entry = ModelUtils.get(proxyModel, index)

                menu.contactId = entry.contactId
                menu.name = entry.name
                menu.currentAddress = entry.walletAddress
                menu.popup(parent, mouse.x, mouse.y)

                holdersList.currentIndex = index
            }
        }
    }

    StatusMenu {
        id: menu

        property string contactId
        property string name
        property string currentAddress
        readonly property bool rawAddress: name === ""

        onClosed: holdersList.currentIndex = -1

        StatusAction {
            text: qsTr("View Profile")
            icon.name: "profile"
            enabled: !menu.rawAddress

            onTriggered: root.viewProfileRequested(menu.contactId)
        }

        StatusAction {
            text: qsTr("View Messages")
            icon.name: "chat"
            enabled: !menu.rawAddress

            onTriggered: root.viewMessagesRequested(menu.contactId)
        }

        StatusAction {
            text: qsTr("Airdrop")
            icon.name: "airdrop"

            onTriggered: root.airdropRequested(menu.currentAddress)
        }

        StatusMenuSeparator {
            visible: remotelyDestructAction.enabled || kickAction.enabled
                     || banAction.enabled
        }

        StatusAction {
            id: remotelyDestructAction

            text: qsTr("Remotely destruct")
            icon.name: "destroy"
            enabled: root.showRemotelyDestructMenuItem
            type: StatusBaseButton.Type.Danger

            onTriggered: root.remoteDestructRequested(menu.name,
                                                      menu.currentAddress)
        }

        StatusAction {
            id: kickAction

            text: qsTr("Kick")
            icon.name: "warning"
            enabled: !menu.rawAddress
            type: StatusBaseButton.Type.Danger

            onTriggered: root.kickRequested(menu.name, menu.contactId,
                                            menu.currentAddress)
        }

        StatusAction {
            id: banAction

            text: qsTr("Ban")
            icon.name: "cancel"
            enabled: !menu.rawAddress
            type: StatusBaseButton.Type.Danger

            onTriggered: root.banRequested(menu.name, menu.contactId,
                                           menu.currentAddress)
        }
    }
}

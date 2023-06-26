import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root

    property string chainShortNames
    property string userProfilePublicKey
    property bool includeWatchOnlyAccount

    signal goToAccountView(var account)
    signal toggleIncludeWatchOnlyAccount()

    QtObject {
        id: d
        readonly property var relatedAccounts: model.keyPair.accounts
        readonly property bool isWatchOnly: model.keyPair.pairType === Constants.keycard.keyPairType.watchOnly
        readonly property bool isPrivateKeyImport: model.keyPair.pairType === Constants.keycard.keyPairType.privateKeyImport
        readonly property bool isProfileKeypair: model.keyPair.pairType === Constants.keycard.keyPairType.profile
        readonly property string locationInfo: model.keyPair.migratedToKeycard ? qsTr("On Keycard"): qsTr("On device")
    }

    implicitHeight: layout.height
    color: Theme.palette.baseColor4
    radius: 8

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        StatusListItem {
            Layout.fillWidth: true
            title: d.isWatchOnly ? qsTr("Watch only") : model.keyPair.name
            statusListItemSubTitle.textFormat: Qt.RichText
            titleTextIcon: model.keyPair.migratedToKeycard ? "keycard": ""
            subTitle: d.isWatchOnly ? "" : d.isProfileKeypair ?
                      Utils.getElidedCompressedPk(model.keyPair.pubKey) + Constants.settingsSection.dotSepString + d.locationInfo : d.locationInfo
            color: Theme.palette.transparent
            ringSettings {
                ringSpecModel: d.isProfileKeypair ? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
                ringPxSize: Math.max(asset.width / 24.0)
            }
            asset {
                width: model.keyPair.icon ? 24 : 40
                height: model.keyPair.icon ? 24 : 40
                name: model.keyPair.image ? model.keyPair.image : model.keyPair.icon
                isImage: !!model.keyPair.image
                color: d.isProfileKeypair ? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
                letterSize: Math.max(4, asset.width / 2.4)
                charactersLen: 2
                isLetterIdenticon: !model.keyPair.icon && !asset.name.toString()
            }
            components: [
                StatusFlatRoundButton {
                    icon.name: "more"
                    icon.color: Theme.palette.directColor1
                    visible: !d.isWatchOnly
                },
                StatusBaseText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Include in total balance")
                    visible: d.isWatchOnly
                },
                StatusSwitch {
                    visible: d.isWatchOnly
                    checked: root.includeWatchOnlyAccount
                    onClicked: root.toggleIncludeWatchOnlyAccount()
                }
            ]
        }
        StatusListView {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 1
            model: d.relatedAccounts
            delegate: WalletAccountDelegate {
                width: ListView.view.width
                account: model.account
                totalCount: ListView.view.count
                chainShortNames: root.chainShortNames
                onGoToAccountView: root.goToAccountView(model.account)
            }
        }
    }
}

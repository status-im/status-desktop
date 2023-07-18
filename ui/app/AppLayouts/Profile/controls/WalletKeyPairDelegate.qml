import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

Rectangle {
    id: root

    property var keyPair
    property string chainShortNames
    property string userProfilePublicKey
    property bool includeWatchOnlyAccount

    signal goToAccountView(var account)
    signal toggleIncludeWatchOnlyAccount()
    signal runRenameKeypairFlow()

    QtObject {
        id: d
        readonly property var relatedAccounts: keyPair.accounts
        readonly property bool isWatchOnly: keyPair.pairType === Constants.keycard.keyPairType.watchOnly
        readonly property bool isPrivateKeyImport: keyPair.pairType === Constants.keycard.keyPairType.privateKeyImport
        readonly property bool isProfileKeypair: keyPair.pairType === Constants.keycard.keyPairType.profile
        readonly property string locationInfo: keyPair.migratedToKeycard ? qsTr("On Keycard"): qsTr("On device")
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
            title: d.isWatchOnly ? qsTr("Watched addresses") : keyPair.name
            statusListItemSubTitle.textFormat: Qt.RichText
            titleTextIcon: keyPair.migratedToKeycard ? "keycard": ""
            subTitle: d.isWatchOnly ? "" : d.isProfileKeypair ?
                      Utils.getElidedCompressedPk(keyPair.pubKey) + Constants.settingsSection.dotSepString + d.locationInfo : d.locationInfo
            color: Theme.palette.transparent
            ringSettings {
                ringSpecModel: d.isProfileKeypair ? Utils.getColorHashAsJson(root.userProfilePublicKey) : []
                ringPxSize: Math.max(asset.width / 24.0)
            }
            asset {
                width: keyPair.icon ? Style.current.bigPadding : 40
                height: keyPair.icon ? Style.current.bigPadding : 40
                name: keyPair.image ? keyPair.image : keyPair.icon
                isImage: !!keyPair.image
                color: d.isProfileKeypair ? Utils.colorForPubkey(root.userProfilePublicKey) : Theme.palette.primaryColor1
                letterSize: Math.max(4, asset.width / 2.4)
                charactersLen: 2
                isLetterIdenticon: !keyPair.icon && !asset.name.toString()
            }
            components: [
                StatusFlatRoundButton {
                    icon.name: "more"
                    icon.color: Theme.palette.directColor1
                    visible: !d.isWatchOnly
                    highlighted: menuLoader.item && menuLoader.item.opened
                    onClicked: {
                        menuLoader.active = true
                        menuLoader.item.popup(0, height)
                    }

                    Loader {
                        id: menuLoader
                        active: false
                        sourceComponent: StatusMenu {
                            onClosed: {
                                menuLoader.active = false
                            }

                            StatusAction {
                                text: enabled? qsTr("Show encrypted QR of keypairs on device") : ""
                                enabled: !d.isProfileKeypair &&
                                         !model.keyPair.migratedToKeycard &&
                                         !model.keyPair.operability === Constants.keypair.operability.nonOperable
                                icon.name: "qr"
                                icon.color: Theme.palette.primaryColor1
                                onTriggered: {
                                    console.warn("TODO: show encrypted QR")
                                }
                            }


                            StatusAction {
                                text: model.keyPair.migratedToKeycard? qsTr("Stop using Keycard") : qsTr("Move keys to a Keycard")
                                icon.name: model.keyPair.migratedToKeycard? "keycard-crossed" : "keycard"
                                icon.color: Theme.palette.primaryColor1
                                onTriggered: {
                                    if (model.keyPair.migratedToKeycard)
                                        console.warn("TODO: stop using Keycard")
                                    else
                                        console.warn("TODO: move keys to a Keycard")
                                }
                            }

                            StatusAction {
                                text: enabled? qsTr("Rename keypair") : ""
                                enabled: !d.isProfileKeypair
                                icon.name: "edit"
                                icon.color: Theme.palette.primaryColor1
                                onTriggered: {
                                    root.runRenameKeypairFlow()
                                }
                            }

                            StatusMenuSeparator {
                                visible: !d.isProfileKeypair
                            }

                            StatusAction {
                                text: enabled? qsTr("Remove keypair and associated accounts") : ""
                                enabled: !d.isProfileKeypair
                                type: StatusAction.Type.Danger
                                icon.name: "delete"
                                icon.color: Theme.palette.dangerColor1
                                onTriggered: {
                                    console.warn("TODO: remove master keys and associated accounts")
                                }
                            }
                        }
                    }
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

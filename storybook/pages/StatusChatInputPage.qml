import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Chat.stores 1.0 as ChatStores

SplitView {
    id: root

    Logs { id: logs }

    QtObject {
        id: globalUtilsMock

        property bool ready: false
        property var globalUtils: QtObject {
            function isCompressedPubKey(publicKey) {
                return false
            }
        }
        Component.onCompleted: {
            Utils.globalUtilsInst = globalUtilsMock.globalUtils
            globalUtilsMock.ready = true
        }
    }

    UsersModel {
        id: fakeUsersModel
    }

    LinkPreviewModel {
        id: fakeLinksModel
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        //dummy item to position chatInput at the bottom
        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
        }

        Loader {
            id: chatInputLoader
            active: globalUtilsMock.ready
            sourceComponent: StatusChatInput {
                id: chatInput
                property string unformattedText: chatInput.textInput.getText(0, chatInput.textInput.length)

                readonly property SQUtils.ModelChangeTracker urlsModelChangeTracker: SQUtils.ModelChangeTracker {
                    model: fakeLinksModel
                }

                onUnformattedTextChanged: {
                    textEditConnection.enabled = false
                    d.loadLinkPreviews(unformattedText)
                    textEditConnection.enabled = true
                }

                Connections {
                    id: textEditConnection
                    target: chatInput.textInput
                    function onTextChanged() {
                        if(unformattedText !== chatInput.textInput.getText(0, chatInput.textInput.length))
                            unformattedText = chatInput.textInput.getText(0, chatInput.textInput.length)
                    }
                }

                enabled: enabledCheckBox.checked
                linkPreviewModel: fakeLinksModel
                urlsList: {
                    urlsModelChangeTracker.revision
                    return SQUtils.ModelUtils.modelToFlatArray(fakeLinksModel, "url")
                }
                askToEnableLinkPreview: askToEnableLinkPreviewSwitch.checked
                onAskToEnableLinkPreviewChanged: {
                    if(askToEnableLinkPreview) {
                        fakeLinksModel.clear()
                        d.loadLinkPreviews(unformattedText)
                    }
                }
                usersModel: fakeUsersModel

                sharedStore: SharedStores.RootStore {
                    property bool gifUnfurlingEnabled: true

                    property var gifStore: SharedStores.GifStore {
                        property var gifColumnA: ListModel {}
                    }
                }

                requestPaymentStore: d.requestPaymentStore

                onSendMessage: {
                    logs.logEvent("StatusChatInput::sendMessage", ["MessageWithPk"], [chatInput.getTextWithPublicKeys()])
                    logs.logEvent("StatusChatInput::sendMessage", ["PlainText"], [SQUtils.StringUtils.plainText(chatInput.getTextWithPublicKeys())])
                    logs.logEvent("StatusChatInput::sendMessage", ["RawText"], [chatInput.textInput.text])
                }
                onEnableLinkPreviewForThisMessage: {
                    linkPreviewSwitch.checked = true
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onEnableLinkPreview: {
                    linkPreviewSwitch.checked = true
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onDisableLinkPreview: {
                    linkPreviewSwitch.checked = false
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onDismissLinkPreviewSettings: {
                    askToEnableLinkPreviewSwitch.checked = false
                    linkPreviewSwitch.checked = false
                }
                onDismissLinkPreview: (index) => {
                    fakeLinksModel.setProperty(index, "unfurled", false)
                    fakeLinksModel.setProperty(index, "immutable", true)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }

        QtObject {
            id: d

            readonly property var walletAssetsStore: WalletStores.WalletAssetsStore {
                id: thisWalletAssetStore
                walletTokensStore: WalletStores.TokensStore {
                    plainTokensBySymbolModel: TokensBySymbolModel {}
                }
                assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
            }

            readonly property SharedStores.RequestPaymentStore requestPaymentStore: SharedStores.RequestPaymentStore {
                currencyStore: SharedStores.CurrenciesStore {}
                flatNetworksModel: NetworksModel.flatNetworks
                processedAssetsModel: d.walletAssetsStore.jointModel
                plainAssetsModel: d.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel
                accountsModel: WalletAccountsModel {}
            }

            property bool linkPreviewsEnabled: linkPreviewSwitch.checked && !askToEnableLinkPreviewSwitch.checked
            onLinkPreviewsEnabledChanged: {
                loadLinkPreviews(chatInputLoader.item ? chatInputLoader.item.unformattedText : "")
            }
            function loadLinkPreviews(text) {
                var words = text.split(/\s+/)

                fakeLinksModel.clear()
                words.forEach(function(word){
                    if(Utils.isURL(word)) {
                        const linkPreview = fakeLinksModel.getStandardLinkPreview()
                        linkPreview.url = encodeURI(word)
                        linkPreview.unfurled = Math.random() > 0.2
                        linkPreview.immutable = !d.linkPreviewsEnabled
                        linkPreview.empty = Math.random() > 0.7
                        fakeLinksModel.append(linkPreview)
                    }
                })
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent
            CheckBox {
                id: enabledCheckBox
                text: "enabled"
                checked: true
            }

            TabBar {
                id: bar
                TabButton {
                    text: "Attachments"
                }
                TabButton {
                    text: "Users"
                }
            }

            StackLayout {
                currentIndex: bar.currentIndex
                ColumnLayout {
                    id: attachmentsTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Label {
                        text: "Images"
                        Layout.fillWidth: true
                    }
                    ComboBox {
                        id: imageNb
                        editable: true
                        model: 20
                        validator: IntValidator {bottom: 0; top: 20;}
                        focus: true
                        onCurrentIndexChanged: {
                            if(!chatInputLoader.item)
                                return
                            const urls = []
                            for (let i = 0; i < imageNb.currentIndex ; i++) {
                                urls.push("https://picsum.photos/200/300?random=" + i)
                            }
                            console.log(urls.length)
                            chatInputLoader.item.fileUrlsAndSources = urls
                        }
                    }
                    Label {
                        text: "Links"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: linkPreviewSwitch
                        text: "Link Preview enabled"
                    }

                    Switch {
                        id: askToEnableLinkPreviewSwitch
                        text: "Ask to enable Link Preview"
                        checked: true
                    }

                    ComboBox {
                        id: linksNb
                        editable: true
                        model: 20
                        validator: IntValidator {bottom: 0; top: 20;}
                        onCurrentIndexChanged: {
                            if(!chatInputLoader.item)
                                return
                            let urls = ""
                            for (let i = 0; i < linksNb.currentIndex ; i++) {
                                urls += "https://www.youtube.com/watch?v=9bZkp7q19f0" + Math.floor(Math.random() * 100) + " "
                            }

                            chatInputLoader.item.textInput.text = urls
                        }
                    }
                }
                UsersModelEditor {
                    id: modelEditor
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: fakeUsersModel

                    onRemoveClicked: fakeUsersModel.remove(index, 1)
                    onRemoveAllClicked: fakeUsersModel.clear()
                    onAddClicked: fakeUsersModel.append(modelEditor.getNewUser(fakeUsersModel.count))
                }
            }
            Label {
                text: "Attachments"
                Layout.fillWidth: true
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=23155-66084&mode=design&t=VWBVK4DOUxr1BmTp-0

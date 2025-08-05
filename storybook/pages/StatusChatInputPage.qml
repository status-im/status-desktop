import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import utils
import shared.status

import StatusQ.Core.Utils as SQUtils
import StatusQ.Controls

SplitView {
    id: root

    function openGifTestPopup(params, cbOnGifSelected, cbOnClose)
    {
        _d.cbOnGifSelected = cbOnGifSelected
        _d.cbOnClose = cbOnClose
        _d.popupParent = params.popupParent
        _d.parentXPosition = _d.popupParent.x + _d.popupParent.width
        _d.parentYPosition = _d.popupParent.y
        _d.closeAfterSelection = params.closeAfterSelection

        let gifPopupInst = gifPopupComponent.createObject(_d.popupParent)
        gifPopupInst.open()
    }

    property QtObject _d: QtObject {
        property var cbOnGifSelected: function () {} // It stores callback for gifSelected
        property var cbOnClose: function () {} // It stores callback for popup closed
        property var popupParent: null // Parent button object type
        property var parentXPosition: null // Parent rigth
        property var parentYPosition: null // Parent bottom
        property bool closeAfterSelection: true
    }

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
                paymentRequestModel: d.paymentRequestModel
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

                paymentRequestFeatureEnabled: true
                areTestNetworksEnabled: testnetEnabledCheckBox.checked

                onSendMessage: {
                    logs.logEvent("StatusChatInput::sendMessage", ["MessageWithPk"], [chatInput.getTextWithPublicKeys()])
                    logs.logEvent("StatusChatInput::sendMessage", ["PlainText"], [SQUtils.StringUtils.plainText(chatInput.getTextWithPublicKeys())])
                    logs.logEvent("StatusChatInput::sendMessage", ["RawText"], [chatInput.textInput.text])
                    imageNb.currentIndex = 0 // images cleared
                    linksNb.currentIndex = 0 // links cleared
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
                onRemovePaymentRequestPreview: (index) => {
                    d.paymentRequestModel.remove(index)
                }
                onOpenGifPopupRequest: (params, cbOnGifSelected, cbOnClose) => {
                                           logs.logEvent("StatusChatInput:openGifPopupRequest --> Open GIF Popup Request!")
                                           root.openGifTestPopup(params, cbOnGifSelected, cbOnClose)
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

            property var paymentRequestModel: ListModel {}

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

            CheckBox {
                id: testnetEnabledCheckBox
                text: "testnet enabled"
                checked: false
            }

            TabBar {
                id: bar
                TabButton {
                    width: implicitWidth
                    text: "Attachments"
                }
                TabButton {
                    width: implicitWidth
                    text: "Users"
                }
                TabButton {
                    width: implicitWidth
                    text: "Payment request"
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

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Button {
                        text: "Add payment request"
                        enabled: paymentRequestAmount.text !== "" && paymentRequestAsset.text !== ""
                        onClicked: {
                            d.paymentRequestModel.append({
                                "amount": paymentRequestAmount.text,
                                "symbol": paymentRequestAsset.text
                            })
                        }
                    }

                    Label { text: "Amount:" }
                    TextField {
                        id: paymentRequestAmount
                    }

                    Label { text: "Asset:" }
                    TextField {
                        id: paymentRequestAsset
                    }
                }
            }
            Label {
                text: "Attachments"
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: gifPopupComponent

        Popup {
            id: testPopup

            x: _d.parentXPosition - width - 8
            y: _d.parentYPosition - height

            ColumnLayout {
                StatusButton {
                    text: "Send GIF 1"
                    onClicked: {

                        _d.cbOnGifSelected("GIF 1", "URL GIF 1")
                        testPopup.close()
                    }
                }
                StatusButton {
                    text: "Send GIF 2"
                    onClicked: {

                        _d.cbOnGifSelected("GIF 2", "URL GIF 2")
                        testPopup.close()
                    }
                }

            }
            onClosed: {
                _d.cbOnClose()
                destroy()
            }

        }
    }
}

// category: Components
// status: good
// https://www.figma.com/design/Mr3rqxxgKJ2zMQ06UAKiWL/Messenger----Desktop-Legacy?node-id=4360-175&m=dev
// https://www.figma.com/design/Mr3rqxxgKJ2zMQ06UAKiWL/Messenger----Desktop-Legacy?node-id=25492-31491&m=dev

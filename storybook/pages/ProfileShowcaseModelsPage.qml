import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ
import StatusQ.Core.Utils
import StatusQ.Core.Theme

import Storybook

import SortFilterProxyModel

import utils

import AppLayouts.Profile.helpers

ColumnLayout {
    ListModel {
        id: accountsModel

        ListElement {
            address: "1"
            name: "Crypto Kitties"
            showcaseKey: "1"
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            showcasePosition: 0
        }
        ListElement {
            address: "2"
            name: "Status"
            showcaseKey: "2"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
        }
        ListElement {
            address: "3";
            name: "Fun Stuff"
            showcaseKey: "3"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
        }
        ListElement {
            address: "4"
            name: "Other Stuff"
            showcaseKey: "4"
            showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        }
    }

    ListModel {
        id: socialLinksModel

        ListElement { showcaseKey: "1"; showcasePosition: 0; text: "Twitter"; url: "https://twitter.com/status" }
        ListElement { showcaseKey: "2"; showcasePosition: 1; text: "Personal Site"; url: "https://status.im" }
        ListElement { showcaseKey: "3"; showcasePosition: 2; text: "Github"; url: "https://github.com" }
        ListElement { showcaseKey: "4"; showcasePosition: 3; text: "Youtube"; url: "https://youtube.com" }
        ListElement { showcaseKey: "5"; showcasePosition: 4; text: "Discord"; url: "https://discord.com" }
        ListElement { showcaseKey: "6"; showcasePosition: 5; text: "Telegram"; url: "https://t.me/status" }
        ListElement { showcaseKey: "7"; showcasePosition: 6; text: "Custom"; url: "https://status.im" }
    }

    ListModel {
        id: collectiblesModel

        ListElement {
            uid: 1
            name: "Collectible 1"
            showcaseKey: "1"
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            showcasePosition: 0
            ownership: [
                ListElement { accountAddress: "1" },
                ListElement { accountAddress: "3" }
            ]
        }
        ListElement {
            uid: 2
            name: "Collectible 2"
            showcaseKey: "2"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            showcasePosition: 2
            ownership: [
                ListElement { accountAddress: "1" },
                ListElement { accountAddress: "2" },
                ListElement { accountAddress: "3" }
            ]
        }
        ListElement {
            uid: 3
            name: "Collectible 3"
            showcaseKey: "3"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            showcasePosition: 1
            ownership: [
                ListElement { accountAddress: "3" }
            ]
        }
        ListElement {
            uid: 4
            name: "Collectible 4"
            showcaseKey: "4"
            showcaseVisibility: Constants.ShowcaseVisibility.NoOne
            showcasePosition: 3
            ownership: [
                ListElement { accountAddress: "1" },
                ListElement { accountAddress: "4" }
            ]
        }
    }

    ProfileShowcaseModels {
        id: showcaseModels

        accountsSourceModel: accountsModel
        collectiblesSourceModel: collectiblesModel
        socialLinksSourceModel: socialLinksModel
    }

    ListModel {
        id: comboBoxModel

        ListElement {
            text: "verified"
            value: Constants.ShowcaseVisibility.IdVerifiedContacts
        }
        ListElement {
            text: "contacts"
            value: Constants.ShowcaseVisibility.Contacts
        }
        ListElement {
            text: "all"
            value: Constants.ShowcaseVisibility.Everyone
        }
    }

    component VisibilityComboBox: ComboBox {
        model: comboBoxModel

        textRole: "text"
        valueRole: "value"
    }

    StackView {
        id: stackView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10

        initialItem: collectiblesView

        Component {
            id: collectiblesView
            RowLayout {
                id: grid
                spacing: 10
                //anchors.fill: parent

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "Backend models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }

                    GenericListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        model: accountsModel
                        label: "ACCOUNTS MODEL"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "Display models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }

                    GenericListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        model: showcaseModels.accountsVisibleModel
                        label: "IN SHOWCASE"
                        movable: true
                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]

                        onMoveRequested: {
                            showcaseModels.changeAccountPosition(from, to);
                        }

                        insetComponent: RowLayout {
                            readonly property var topModel: model

                            RoundButton {
                                text: "❌"
                                onClicked: showcaseModels.setAccountVisibility(
                                    model.showcaseKey,
                                    Constants.ShowcaseVisibility.NoOne)
                            }

                            VisibilityComboBox {
                                property bool completed: false

                                onCurrentValueChanged: {
                                    if (!completed || topModel.index < 0)
                                        return

                                    showcaseModels.setAccountVisibility(
                                        topModel.showcaseKey, currentValue)
                                }

                                Component.onCompleted: {
                                    currentIndex = indexOfValue(topModel.showcaseVisibility)
                                    completed = true
                                }
                            }
                        }
                    }

                    GenericListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        model: showcaseModels.accountsHiddenModel

                        label: "HIDDEN"

                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]

                        insetComponent: Button {
                            text: "unhide"

                            onClicked:
                                showcaseModels.setAccountVisibility(
                                    model.showcaseKey,
                                    Constants.ShowcaseVisibility.IdVerifiedContacts)
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Label {
                        text: "Backend models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }
                    GenericListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        model: collectiblesModel
                        label: "COLLECTIBLES MODEL"
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        text: "Display models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }

                    GenericListView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        model: showcaseModels.collectiblesVisibleModel
                        label: "IN SHOWCASE"
                        movable: true
                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition", "maxVisibility"]

                        onMoveRequested: {
                            showcaseModels.changeCollectiblePosition(from, to);
                        }

                        insetComponent: RowLayout {
                            readonly property var topModel: model

                            RoundButton {
                                text: "❌"
                                onClicked: showcaseModels.setCollectibleVisibility(
                                    model.showcaseKey,
                                    Constants.ShowcaseVisibility.NoOne)
                            }

                            VisibilityComboBox {
                                property bool completed: false

                                onCurrentValueChanged: {
                                    if (!completed || topModel.index < 0)
                                        return

                                    showcaseModels.setCollectibleVisibility(
                                        topModel.showcaseKey, currentValue)
                                }

                                Component.onCompleted: {
                                    currentIndex = indexOfValue(topModel.showcaseVisibility)
                                    completed = true
                                }
                            }
                        }
                    }

                    GenericListView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        model: showcaseModels.collectiblesHiddenModel

                        label: "HIDDEN"

                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition",
                            "accounts", "maxVisibility"]

                        insetComponent: Button {
                            text: "unhide"

                            onClicked:
                                showcaseModels.setCollectibleVisibility(
                                    model.showcaseKey,
                                    Constants.ShowcaseVisibility.IdVerifiedContacts)
                        }
                    }
                }
            }
        }

        Component {
            id: webView
            Flickable {

                contentWidth: webGrid.implicitWidth
                contentHeight: webGrid.implicitHeight

                Grid {
                    id: webGrid

                    rows: 3
                    columns: 4

                    spacing: 10

                    flow: Grid.TopToBottom

                    Label {
                        text: "Backend models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }

                    GenericListView {
                        width: 300
                        height: 300

                        model: socialLinksModel
                        label: "SOCIAL LINKS MODEL"
                    }

                    Item {

                        width: 300
                        height: 300
                    }

                    Label {
                        text: "Display models"
                        font.pixelSize: Theme.fontSize22
                        padding: 10
                    }

                    GenericListView {
                        width: 610
                        height: 300

                        model: showcaseModels.socialLinksVisibleModel

                        label: "IN SHOWCASE"
                        movable: true

                        onMoveRequested: {
                            showcaseModels.changeSocialLinkPosition(from, to);
                        }
                    }
                }
            }
        }
    }

    Label {
        text: `accounts in showcase: [${showcaseModels.visibleAccountsList}]`
        Layout.alignment: Qt.AlignHCenter
    }

    Label {
        readonly property string visibilities:
            JSON.stringify(showcaseModels.accountsVisibilityMap)

        text: `accounts visibilities: [${visibilities}]`
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter

        Button {
            text: "Collectibles tab"
            onClicked: {
                stackView.replace(webView, collectiblesView)
            }
        }

        Button {
            text: "Web tab"
            onClicked: {
                stackView.replace(collectiblesView, webView)
            }
        }
    }



    Button {
        text: "SAVE"

        onClicked: {
            const accountsToBeSaved = showcaseModels.accountsCurrentState()
            const collectiblesToBeSaved = showcaseModels.collectiblesCurrentState()

            for (let index = 0; index < accountsModel.count; index++) {
                let account = accountsModel.get(index)
                const showcaseAccount = accountsToBeSaved.find(item => item.showcaseKey === account.showcaseKey)

                account.showcasePosition = !!showcaseAccount ? showcaseAccount.showcasePosition : 0
                account.showcaseVisibility = !!showcaseAccount ? showcaseAccount.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
                accountsModel.set(index, account)
            }

            for (let index = 0; index < collectiblesModel.count; index++) {
                let collectible = collectiblesModel.get(index)
                const showcaseCollectible = collectiblesToBeSaved.find(item => item.showcaseKey === collectible.showcaseKey)

                collectible.showcasePosition = !!showcaseCollectible ? showcaseCollectible.showcasePosition : 0
                collectible.showcaseVisibility = !!showcaseCollectible ? showcaseCollectible.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
                collectiblesModel.set(index, collectible)
            }
        }

        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 10
    }
}

// category: Models

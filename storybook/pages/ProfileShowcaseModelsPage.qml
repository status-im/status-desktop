import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import AppLayouts.Profile.helpers 1.0

ColumnLayout {
    ListModel {
        id: accountsModel

        ListElement { address: "1"; name: "Crypto Kitties" }
        ListElement { address: "2"; name: "Status" }
        ListElement { address: "3"; name: "Fun Stuff" }
        ListElement { address: "4"; name: "Other Stuff" }
    }

    ListModel {
        id: socialLinksModel

        ListElement { uuid: "1"; text: "Twitter"; url: "https://twitter.com/status" }
        ListElement { uuid: "2"; text: "Personal Site"; url: "https://status.im" }
        ListElement { uuid: "3"; text: "Github"; url: "https://github.com" }
        ListElement { uuid: "4"; text: "Youtube"; url: "https://youtube.com" }
        ListElement { uuid: "5"; text: "Discord"; url: "https://discord.com" }
        ListElement { uuid: "6"; text: "Telegram"; url: "https://t.me/status" }
        ListElement { uuid: "7"; text: "Custom"; url: "https://status.im" }
    }

    ListModel {
        id: accountsShowcaseModel
        ListElement {
            address: "1"
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            order: 0
            name: "name"
            colorId: "colorId"
            emoji: "emoji"
        }
        ListElement {
            address: "2"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            order: 1
            name: "name"
            colorId: "colorId"
            emoji: "emoji"
        }
        ListElement {
            address: "3"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            order: 2
            name: "name"
            colorId: "colorId"
            emoji: "emoji"
        }
    }

    ListModel {
        id: accounts13
        ListElement { accountAddress: "1" }
        ListElement { accountAddress: "3" }
    }

    ListModel {
        id: accounts3
        ListElement { accountAddress: "3" }
    }

    ListModel {
        id: accounts123
        ListElement { accountAddress: "1" }
        ListElement { accountAddress: "2" }
        ListElement { accountAddress: "3" }
    }

    ListModel {
        id: accounts14
        ListElement { accountAddress: "1" }
        ListElement { accountAddress: "4" }
    }

    ListModel {
        id: collectiblesListModel

        ListElement { item: 1 }
        ListElement { item: 2 }
        ListElement { item: 3 }
        ListElement { item: 4 }
    }

    SortFilterProxyModel {
        id: collectiblesModel
        sourceModel: collectiblesListModel
        proxyRoles: [
            FastExpressionRole {
                name: "ownership"
                expression: {
                    if (index == 0) {
                        return accounts13
                    } else if (index == 1) {
                        return accounts3
                    } else if (index == 2) {
                        return accounts123
                    } else if (index == 3) {
                        return accounts14
                    }
                    return undefined
                }
            },
            FastExpressionRole {
                name: "uid"
                expression: {
                    return index + 1
                }
            },
            FastExpressionRole {
                name: "name"
                expression: {
                    return "Collectible " + (index + 1)
                }
            }
        ]
    }

    ListModel {
        id: collectiblesShowcaseModel
        ListElement {
            uid: "1"
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            order: 0
            name: "name"
            backgroundColor: "backgroundColor"
            chainId: "chainId"
            communityId: "communityId"
            collectionName: "collectionName"
            imageUrl: "imageUrl"
            isLoading: "isLoading"
            contractAddress: "contractAddress"
            tokenId: "tokenId"
        }
        ListElement {
            uid: "2"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            order: 2
            name: "name"
            backgroundColor: "backgroundColor"
            chainId: "chainId"
            communityId: "communityId"
            collectionName: "collectionName"
            imageUrl: "imageUrl"
            isLoading: "isLoading"
            contractAddress: "contractAddress"
            tokenId: "tokenId"
        }
        ListElement {
            uid: "3"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            order: 1
            name: "name"
            backgroundColor: "backgroundColor"
            chainId: "chainId"
            communityId: "communityId"
            collectionName: "collectionName"
            imageUrl: "imageUrl"
            isLoading: "isLoading"
            contractAddress: "contractAddress"
            tokenId: "tokenId"
        }
    }

    ProfileShowcaseModels {
        id: showcaseModels

        accountsSourceModel: accountsModel
        accountsShowcaseModel: accountsShowcaseModel

        collectiblesSourceModel: collectiblesModel
        collectiblesShowcaseModel: collectiblesShowcaseModel

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
            Flickable {

                contentWidth: grid.width
                contentHeight: grid.height

                clip: true

                Grid {
                    id: grid

                    rows: 3
                    columns: 4

                    spacing: 10

                    flow: Grid.TopToBottom

                    Label {
                        text: "Backend models"
                        font.pixelSize: 22
                        padding: 10
                    }

                    GenericListView {
                        width: 300
                        height: 300

                        model: accountsModel
                        label: "ACCOUNTS MODEL"
                    }

                    GenericListView {
                        width: 300
                        height: 300

                        model: accountsShowcaseModel
                        label: "SHOWCASE MODEL"
                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]
                    }

                    Label {
                        text: "Display models"
                        font.pixelSize: 22
                        padding: 10
                    }

                    GenericListView {
                        width: 420
                        height: 300

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
                        width: 420
                        height: 300

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

                    Label {
                        text: "Backend models"
                        font.pixelSize: 22
                        padding: 10
                    }

                    GenericListView {
                        width: 270
                        height: 300

                        model: collectiblesModel
                        label: "COLLECTIBLES MODEL"
                    }

                    GenericListView {
                        width: 270
                        height: 300

                        model: collectiblesShowcaseModel
                        label: "SHOWCASE MODEL"
                        roles: ["uid", "showcaseVisibility", "order"]
                    }

                    Label {
                        text: "Display models"
                        font.pixelSize: 22
                        padding: 10
                    }

                    GenericListView {
                        width: 610
                        height: 300

                        model: showcaseModels.collectiblesVisibleModel
                        label: "IN SHOWCASE"
                        movable: true
                        roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]

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
                        width: 610
                        height: 300

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
                        font.pixelSize: 22
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
                        font.pixelSize: 22
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
        //TODO: enable when showcaseModels backend APIs is integrated
        enabled: false

        onClicked: {
            const accountsToBeSaved = showcaseModels.accountsCurrentState()
            const collectiblesToBeSaved = showcaseModels.collectiblesCurrentState()

            accountsShowcaseModel.clear()
            accountsShowcaseModel.append(accountsToBeSaved)

            collectiblesShowcaseModel.clear()
            collectiblesShowcaseModel.append(collectiblesToBeSaved)
        }

        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 10
    }
}

// category: Models

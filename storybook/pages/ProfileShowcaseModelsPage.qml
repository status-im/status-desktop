import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

import utils 1.0

import AppLayouts.Profile.helpers 1.0

ColumnLayout {
    ListModel {
        id: accountsModel

        ListElement { key: "1"; name: "Crypto Kitties" }
        ListElement { key: "2"; name: "Status" }
        ListElement { key: "3"; name: "Fun Stuff" }
        ListElement { key: "4"; name: "Other Stuff" }
    }

    ListModel {
        id: accountsShowcaseModel

        ListElement {
            key: "1"
            visibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            position: 0
        }
        ListElement {
            key: "3"
            visibility: Constants.ShowcaseVisibility.Contacts
            position: 9
        }
    }

    ListModel {
        id: collectiblesModel

        ListElement { key: "1"; name: "Collectible 1"; accounts: "1:3" }
        ListElement { key: "2"; name: "Collectible 2"; accounts: "3" }
        ListElement { key: "3"; name: "Collectible 3"; accounts: "1:2:3" }
        ListElement { key: "4"; name: "Collectible 4"; accounts: "1:4" }
    }

    ListModel {
        id: collectiblesShowcaseModel

        ListElement {
            key: "1"
            visibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            position: 0
        }
        ListElement {
            key: "2"
            visibility: Constants.ShowcaseVisibility.Contacts
            position: 2
        }
        ListElement {
            key: "3"
            visibility: Constants.ShowcaseVisibility.Contacts
            position: 1
        }
    }

    ProfileShowcaseModels {
        id: showcaseModels

        accountsSourceModel: accountsModel
        accountsShowcaseModel: accountsShowcaseModel

        collectiblesSourceModel: collectiblesModel
        collectiblesShowcaseModel: collectiblesShowcaseModel
    }

    MovableModel {
        id: accountsMovableModel

        sourceModel: showcaseModels.accountsVisibleModel
    }

    MovableModel {
        id: collectiblesMovableModel

        sourceModel: showcaseModels.collectiblesVisibleModel
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

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 10

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
                width: 200
                height: 300

                model: accountsModel
                label: "ACCOUNTS MODEL"
            }

            GenericListView {
                width: 200
                height: 300

                model: accountsShowcaseModel
                label: "SHOWCASE MODEL"
                roles: ["key", "visibility", "position"]
            }

            Label {
                text: "Display models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: 420
                height: 300

                model: accountsMovableModel
                label: "IN SHOWCASE"
                movable: true
                roles: ["key", "visibility", "position"]

                onMoveRequested: {
                    accountsMovableModel.move(from, to)

                    const key = ModelUtils.get(accountsMovableModel, to, "key")
                    showcaseModels.changeAccountPosition(key, to);
                }

                insetComponent: RowLayout {
                    readonly property var topModel: model

                    RoundButton {
                        text: "❌"
                        onClicked: showcaseModels.setAccountVisibility(
                                       model.key,
                                       Constants.ShowcaseVisibility.NoOne)
                    }

                    VisibilityComboBox {
                        property bool completed: false

                        onCurrentValueChanged: {
                            if (!completed || topModel.index < 0)
                                return

                            showcaseModels.setAccountVisibility(
                                        topModel.key, currentValue)
                        }

                        Component.onCompleted: {
                            currentIndex = indexOfValue(topModel.visibility)
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

                roles: ["key", "visibility", "position"]

                insetComponent: Button {
                    text: "unhide"

                    onClicked:
                        showcaseModels.setAccountVisibility(
                            model.key,
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

                roles: ["key", "name", "accounts"]
            }

            GenericListView {
                width: 270
                height: 300

                model: collectiblesShowcaseModel
                label: "SHOWCASE MODEL"
                roles: ["key", "visibility", "position"]
            }

            Label {
                text: "Display models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: 610
                height: 300

                model: collectiblesMovableModel
                label: "IN SHOWCASE"
                movable: true
                roles: ["key", "visibility", "position", "accounts", "maxVisibility"]

                onMoveRequested: {
                    collectiblesMovableModel.move(from, to)

                    const key = ModelUtils.get(collectiblesMovableModel, to, "key")
                    showcaseModels.changeCollectiblePosition(key, to);
                }

                insetComponent: RowLayout {
                    readonly property var topModel: model

                    RoundButton {
                        text: "❌"
                        onClicked: showcaseModels.setCollectibleVisibility(
                                       model.key,
                                       Constants.ShowcaseVisibility.NoOne)
                    }

                    VisibilityComboBox {
                        property bool completed: false

                        onCurrentValueChanged: {
                            if (!completed || topModel.index < 0)
                                return

                            showcaseModels.setCollectibleVisibility(
                                        topModel.key, currentValue)
                        }

                        Component.onCompleted: {
                            currentIndex = indexOfValue(topModel.visibility)
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

                roles: ["key", "visibility", "position",
                    "accounts", "maxVisibility"]

                insetComponent: Button {
                    text: "unhide"

                    onClicked:
                        showcaseModels.setCollectibleVisibility(
                            model.key,
                            Constants.ShowcaseVisibility.IdVerifiedContacts)
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

    Button {
        text: "SAVE"

        onClicked: {
            const accountsToBeSaved = showcaseModels.accountsCurrentState()
            const collectiblesToBeSaved = showcaseModels.collectiblesCurrentState()

            accountsMovableModel.syncOrder()
            collectiblesMovableModel.syncOrder()

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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Utils
import AppLayouts.Profile.helpers
import utils

import Storybook

import QtModelsToolkit

Item {
    id: root

    ListModel {
        id: communitiesModel

        ListElement { showcaseKey: "1"; name: "Crypto Kitties"; showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts; showcasePosition: 0 }
        ListElement { showcaseKey: "2"; name: "Status" }
        ListElement { showcaseKey: "3"; name: "Fun Stuff"; showcaseVisibility: Constants.ShowcaseVisibility.Contacts; showcasePosition: 9}
        ListElement { showcaseKey: "4"; name: "Other Stuff" }
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

    ProfileShowcaseDirtyState {
        id: dirtyState

        sourceModel: communitiesModel
    }

    MovableModel {
        id: movableModel

        sourceModel: dirtyState.visibleModel
    }

    ColumnLayout {
        anchors.fill: parent

        Grid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10

            rows: 2
            columns: 2

            spacing: 10

            flow: Grid.TopToBottom

            GenericListView {
                width: grid.width / 2 - grid.spacing
                height: 300

                model: communitiesModel
                label: "COMMUNITIES MODEL - Backend model"
            }

            GenericListView {
                width: grid.width / 2 - grid.spacing
                height: 300

                model: dirtyState.writable_
                label: "WRITABLE MODEL - Internal Model"
                roles: ["showcaseKey", "showcaseVisibility", "showcasePosition", "name"]
            }

            GenericListView {
                width: grid.width / 2 - grid.spacing
                height: 300

                model: movableModel
                label: "IN SHOWCASE - output"
                movable: true
                roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]

                onMoveRequested: {
                    movableModel.move(from, to)
                    dirtyState.changePosition(from, to);
                }

                insetComponent: RowLayout {
                    readonly property var topModel: model

                    RoundButton {
                        text: "❌"
                        onClicked: dirtyState.setVisibility(
                                       model.showcaseKey,
                                       Constants.ShowcaseVisibility.NoOne)
                    }

                    ComboBox {
                        model: comboBoxModel

                        onCurrentValueChanged: {
                            if (!completed || topModel.index < 0)
                                return

                            dirtyState.setVisibility(topModel.showcaseKey, currentValue)
                        }

                        property bool completed: false

                        Component.onCompleted: {
                            currentIndex = indexOfValue(topModel.showcaseVisibility)
                            completed = true
                        }

                        textRole: "text"
                        valueRole: "value"
                    }
                }
            }

            GenericListView {
                width: grid.width / 2 - grid.spacing
                height: 300

                model: dirtyState.hiddenModel
                label: "HIDDEN - output"

                roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]

                insetComponent: Button {
                    text: "unhide"

                    onClicked: dirtyState.setVisibility(
                                   model.showcaseKey,
                                   Constants.ShowcaseVisibility.IdVerifiedContacts)
                }
            }
        }

        Button {
            text: "SAVE"
            onClicked: {
                const toBeSaved = dirtyState.currentState()

                for (let i = 0; i < communitiesModel.count; i++) {
                    const item = communitiesModel.get(i)
                    const found = toBeSaved.find((x) => x.showcaseKey === item.showcaseKey)

                    item.showcaseVisibility = !!found ? found.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
                    item.showcasePosition = !!found ? found.showcasePosition : 0
                }
            }

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 10
        }
    }
}

// category: Models

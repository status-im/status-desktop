import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

import AppLayouts.Profile.helpers 1.0

import utils 1.0

Item {
    id: root

    ListModel {
        id: communitiesModel

        ListElement { showcaseKey: "1"; name: "Crypto Kitties" }
        ListElement { showcaseKey: "2"; name: "Status" }
        ListElement { showcaseKey: "3"; name: "Fun Stuff" }
        ListElement { showcaseKey: "4"; name: "Other Stuff" }
    }

    ListModel {
        id: communitiesShowcaseModel

        ListElement {
            showcaseKey: "1"
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            showcasePosition: 0
        }
        ListElement {
            showcaseKey: "3"
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            showcasePosition: 9
        }
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
        showcaseModel: communitiesShowcaseModel
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

            rows: 3
            columns: 3

            spacing: 10

            flow: Grid.TopToBottom

            Label {
                text: "Backend models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: grid.width / 3 - grid.spacing
                height: 300

                model: communitiesModel
                label: "COMMUNITIES MODEL"
            }

            GenericListView {
                width: grid.width / 3 - grid.spacing
                height: 300

                model: communitiesShowcaseModel
                label: "SHOWCASE MODEL"
                roles: ["showcaseKey", "showcaseVisibility", "showcasePosition"]
            }

            Label {
                text: "Internal models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: grid.width / 3 - grid.spacing
                height: 300

                model: dirtyState.joined_
                label: "JOINED MODEL"
            }

            GenericListView {
                width: grid.width / 3 - grid.spacing
                height: 300

                model: dirtyState.writable_
                label: "WRITABLE MODEL"
                roles: ["showcaseKey", "showcaseVisibility", "showcasePosition", "name"]
            }


            Label {
                text: "Display models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: grid.width / 3 - grid.spacing
                height: 300

                model: movableModel
                label: "IN SHOWCASE"
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
                width: grid.width / 3 - grid.spacing
                height: 300

                model: dirtyState.hiddenModel
                label: "HIDDEN"

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

                communitiesShowcaseModel.clear()
                communitiesShowcaseModel.append(toBeSaved)
            }

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 10
        }
    }
}

// category: Models

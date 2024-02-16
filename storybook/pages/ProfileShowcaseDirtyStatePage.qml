import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

import AppLayouts.Profile.helpers 1.0

Item {
    id: root

    ListModel {
        id: communitiesModel

        ListElement { key: "1"; name: "Crypto Kitties" }
        ListElement { key: "2"; name: "Status" }
        ListElement { key: "3"; name: "Fun Stuff" }
        ListElement { key: "4"; name: "Other Stuff" }
    }

    ListModel {
        id: communitiesShowcaseModel

        ListElement { key: "1"; visibility: 1; position: 0 }
        ListElement { key: "3"; visibility: 2; position: 9 }
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
                width: 200
                height: 300

                model: communitiesModel
                label: "COMMUNITIES MODEL"
            }

            GenericListView {
                width: 200
                height: 300

                model: communitiesShowcaseModel
                label: "SHOWCASE MODEL"
                roles: ["key", "visibility", "position"]
            }

            Label {
                text: "Internal models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: 350
                height: 300

                model: dirtyState.joined_
                label: "JOINED MODEL"
            }

            GenericListView {
                width: 350
                height: 300

                model: dirtyState.writable_
                label: "WRITABLE MODEL"
                roles: ["key", "visibility", "position", "name"]
            }


            Label {
                text: "Display models"
                font.pixelSize: 22
                padding: 10
            }

            GenericListView {
                width: 450
                height: 300

                model: movableModel
                label: "IN SHOWCASE"
                movable: true
                roles: ["key", "visibility", "position"]

                onMoveRequested: {
                    movableModel.move(from, to)

                    const key = ModelUtils.get(movableModel, to, "key")
                    dirtyState.changePosition(key, to);
                }

                insetComponent: RowLayout {
                    readonly property var topModel: model

                    RoundButton {
                        text: "❌"
                        onClicked: dirtyState.setVisibility(model.key, 0)
                    }

                    ComboBox {
                        id: combo

                        model: ListModel {
                            ListElement { text: "contacts"; value: 1 }
                            ListElement { text: "verified"; value: 2 }
                            ListElement { text: "all"; value: 3 }
                        }

                        onCurrentValueChanged: {
                            if (!completed || topModel.index < 0)
                                return

                            dirtyState.setVisibility(topModel.key, currentValue)
                        }

                        property bool completed: false

                        Component.onCompleted: {
                            currentIndex = indexOfValue(topModel.visibility)
                            completed = true
                        }

                        textRole: "text"
                        valueRole: "value"
                    }
                }
            }

            GenericListView {
                width: 450
                height: 300

                model: dirtyState.hiddenModel
                label: "HIDDEN"

                roles: ["key", "visibility", "position"]

                insetComponent: Button {
                    text: "unhide"

                    onClicked: dirtyState.setVisibility(model.key, 1)
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

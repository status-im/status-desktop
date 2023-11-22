import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Qt.labs.qmlmodels 1.0

Item {
    id: root

    ListModel {
        id: firstModel

        ListElement {
            name: "entry 1 (1)"
        }
        ListElement {
            name: "entry 2 (1)"
        }
        ListElement {
            name: "entry 3 (1)"
        }
        ListElement {
            name: "entry 4 (1)"
        }
        ListElement {
            name: "entry 5 (1)"
        }
        ListElement {
            name: "entry 6 (1)"
        }
        ListElement {
            name: "entry 7 (1)"
        }
        ListElement {
            name: "entry 8 (1)"
        }
    }

    ListModel {
        id: secondModel

        ListElement {
            name: "entry 1 (2)"
            key: 1
        }
        ListElement {
            key: 2
            name: "entry 2 (2)"
        }
        ListElement {
            key: 3
            name: "entry 3 (2)"
        }
    }

    ConcatModel {
        id: concatModel

        sources: [
            SourceModel {
                model: firstModel
                markerRoleValue: "first_model"
            },
            SourceModel {
                model: secondModel
                markerRoleValue: "second_model"
            }
        ]

        markerRoleName: "which_model"
        expectedRoles: ["key", "name"]
    }

    RowLayout {
        anchors.fill: parent

        ColumnLayout {

            Layout.preferredWidth: parent.width / 3

            ListView {
                id: firstModelListView

                spacing: 15

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: firstModel

                delegate: RowLayout {
                    width: ListView.view.width

                    Label {
                        Layout.fillWidth: true

                        font.bold: true
                        text: model.name

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                firstModel.setProperty(model.index, "name",
                                                       firstModel.get(model.index).name + "_")
                            }
                        }
                    }
                }
            }

            Button {
                text: "append"

                onClicked: {
                    firstModel.append({name: "appended entry (1)"})
                }
            }

            Button {
                text: "insert at 1"

                onClicked: {
                    firstModel.insert(1, {name: "inserted entry (1)"})
                }
            }
        }

        ColumnLayout {

            Layout.preferredWidth: parent.width / 3
            Layout.fillHeight: true

            ListView {
                id: secondModelListView

                spacing: 15

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: secondModel

                delegate: RowLayout {
                    width: ListView.view.width

                    Label {
                        Layout.fillWidth: true

                        font.bold: true
                        text: model.name

                        MouseArea {
                            anchors.fill: parent

                            onClicked: secondModel.setProperty(
                                           model.index, "name",
                                           secondModel.get(model.index).name + "_")
                        }
                    }
                }
            }

            Button {
                text: "append"

                onClicked: {
                    secondModel.append({name: "appended entry (1)", key: 34})
                }
            }

            Button {
                text: "insert at 1"

                onClicked: {
                    secondModel.insert(1, {name: "inserted entry (1)", key: 999})
                }
            }
        }

        ColumnLayout {

            Layout.preferredWidth: parent.width / 3
            Layout.fillHeight: true

            ListView {
                id: concatListView

                spacing: 15

                Layout.fillWidth: true
                Layout.fillHeight: true

                model: concatModel

                ScrollBar.vertical: ScrollBar {}

                section.property: "which_model"
                section.delegate: ColumnLayout {
                    Label {
                        height: implicitHeight * 2
                        text: section + " inset"
                        font.pixelSize: 20
                        font.bold: true
                        font.underline: true

                        color: "darkred"

                        verticalAlignment: Text.AlignVCenter
                    }

                    RowLayout {
                        CheckBox {
                            text: "some switch here"
                        }
                        CheckBox {
                            text: "some other switch here"
                        }
                    }
                }

                delegate: DelegateChooser {
                    id: chooser
                    role: "which_model"

                    DelegateChoice {
                        roleValue: "first_model"

                        RowLayout {
                            width: ListView.view.width

                            Label {
                                Layout.fillWidth: true

                                font.bold: true
                                text: model.name + ", " + model.which_model
                                color: "darkgreen"
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "second_model"

                        RowLayout {
                            width: ListView.view.width

                            Label {
                                Layout.fillWidth: true

                                font.bold: true
                                text: model.name + ", " + model.which_model
                                      + " (" + model.key + ")"
                                color: "darkblue"
                            }
                        }
                    }
                }
            }

            Label {
                text: concatListView.count
            }
        }
    }
}

// category: Models

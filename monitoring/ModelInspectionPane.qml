import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Monitoring 1.0


Pane {
    property string name
    property var model
    readonly property var rootModel: model

    property bool showControls: true

    readonly property var roles: model ? Monitor.modelRoles(model) : []

    readonly property var rolesModelContent: roles.map(role => ({
        visible: true,
        name: role.name,
        width: Math.ceil(fontMetrics.advanceWidth(`  ${role.name}  `))
    }))

    onRolesModelContentChanged: {
        rolesModel.clear()
        rolesModel.append(rolesModelContent)
    }

    property int columnsTotalWidth:
        rolesModelContent.reduce((a, x) => a + x.width, 0)

    ListModel {
        id: rolesModel

        Component.onCompleted: {
            clear()
            append(rolesModelContent)
        }
    }

    Control {
        id: helperControl

        font.bold: true
    }

    FontMetrics {
        id: fontMetrics

        font.bold: true
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true

            visible: showControls

            RoundButton {
                text: "⬅️"

                onClicked: {
                    inspectionStackView.pop(StackView.Immediate)
                }
            }

            TextInput {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                text: name
                font.pixelSize: 20
                font.bold: true

                selectByMouse: true
                readOnly: true
            }
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        Label {
            visible: showControls

            text: "Hint: use right/left button click on a column " +
                  "header to adjust width, press cell content to " +
                  "see full value"
        }

        Label {
            text: model ? `rows count: ${model.rowCount()}` : ""
            font.bold: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.vertical: ScrollBar {}
            ScrollBar.horizontal: ScrollBar {}

            clip: true
            contentWidth: columnsTotalWidth
            flickableDirection: Flickable.AutoFlickDirection

            model: rootModel

            delegate: Rectangle {
                implicitWidth: flow.implicitWidth
                implicitHeight: flow.implicitHeight

                readonly property var topModel: model

                Row {
                    id: flow

                    Repeater {
                        model: rolesModel

                        Label {
                            id: label

                            width: model.width
                            height: implicitHeight * 1.2

                            text: {
                                const value = topModel[model.name]

                                if (value === undefined || value === null)
                                    return ""

                                const isModel = Monitor.isModel(value)

                                let text = value.toString()

                                if (isModel) {
                                    text += " (" + value.rowCount() + ")"
                                }

                                return text
                            }

                            elide: Text.ElideRight
                            maximumLineCount: 1
                            verticalAlignment: Text.AlignVCenter

                            leftPadding: 2
                            rightPadding: 1

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: "gray"
                            }

                            Rectangle {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                width: 1
                                color: "gray"
                            }

                            MouseArea {
                                id: labelMouseArea

                                anchors.fill: parent

                                onClicked: {
                                    const value = topModel[model.name]
                                    const isModel = Monitor.isModel(value)

                                    if (isModel)
                                        loader.active = true
                                }
                            }

                            Loader {
                                id: loader

                                active: false
                                sourceComponent: ApplicationWindow {
                                    width: 500
                                    height: 400
                                    visible: true

                                    onClosing: loader.active = false

                                    Loader {
                                        anchors.fill: parent
                                        sourceComponent: modelInspectionComponent

                                        Component.onCompleted: {
                                            item.showControls = false
                                            item.model = topModel[model.name]
                                        }
                                    }
                                }
                            }

                            ToolTip.visible: labelMouseArea.pressed
                            ToolTip.text: label.text
                        }
                    }
                }
            }

            headerPositioning: ListView.OverlayHeader

            header: Item {
                implicitWidth: headerFlow.implicitWidth
                implicitHeight: headerFlow.implicitHeight * 1.5
                z: 2

                Rectangle {
                    color: "whitesmoke"
                    anchors.fill: parent
                    border.color: "gray"
                }

                Row {
                    id: headerFlow

                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: rolesModel

                        Label {
                            text: `  ${model.name}  `
                            font.bold: true

                            width: model.width
                            elide: Text.ElideRight
                            maximumLineCount: 1

                            MouseArea {
                                anchors.fill: parent

                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: {
                                    const factor = 1.5
                                    const oldWidth = model.width
                                    const leftBtn = mouse.button === Qt.LeftButton

                                    const newWidth
                                        = Math.ceil(leftBtn ? oldWidth * factor : oldWidth / factor)

                                    model.width = newWidth
                                    columnsTotalWidth += newWidth - oldWidth
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

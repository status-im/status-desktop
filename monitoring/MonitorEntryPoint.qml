import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Monitoring 1.0


Component {
    SplitView {
        id: root

        ColumnLayout {
            SplitView.fillHeight: true
            SplitView.preferredWidth: 450

            spacing: 5

            Label {
                Layout.fillWidth: true
                Layout.margins: 5

                text: "Context properties:"
                font.bold: true
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 5

                model: Monitor.contexPropertiesModel

                clip: true
                spacing: 5

                delegate: Item {
                    implicitWidth: delegateRow.implicitWidth
                    implicitHeight: delegateRow.implicitHeight

                    readonly property var contextPropertyValue:
                        MonitorUtils.contextPropertyBindingHelper(name, root).value

                    Row {
                        id: delegateRow

                        Label {
                            text: name
                        }

                        Label {
                            text: ` [${MonitorUtils.typeName(contextPropertyValue)}]`
                            color: "darkgreen"
                        }

                        Label {
                            text: ` (${MonitorUtils.valueToString(contextPropertyValue)})`
                            color: "darkred"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            inspectionStackView.clear()

                            const props = {
                                name: name,
                                objectForInspection: contextPropertyValue
                            }

                            inspectionStackView.push(inspectionList, props)
                        }
                    }
                }
            }
        }

        Component {
            id: modelInspectionComponent

            Pane {
                property string name
                property var model
                readonly property var rootModel: model

                readonly property var roles: Monitor.modelRoles(model)

                readonly property var rolesModelContent: roles.map(role => ({
                    visible: true,
                    name: role.name,
                    width: Math.ceil(fontMetrics.advanceWidth(`  ${role.name}  `))
                }))

                property int columnsTotalWidth:
                    rolesModelContent.reduce((a, x) => a + x.width, 0)

                ListModel {
                    id: rolesModel

                    Component.onCompleted: append(rolesModelContent)
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

                        RoundButton {
                            text: "⬅️"

                            onClicked: {
                                inspectionStackView.pop(StackView.Immediate)
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            text: name
                            font.pixelSize: 20
                            font.bold: true
                        }
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Hint: use right/left button click on a column " +
                              "header to ajust width, press cell content to " +
                              "see full value"
                    }

                    Label {
                        text: `rows count: ${model.rowCount()}`
                        font.bold: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

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

                                        text: topModel[model.name].toString()
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
        }

        Component {
            id: inspectionList

            Pane {
                id: inspectionPanel

                property var objectForInspection
                property string name

                onObjectForInspectionChanged: {
                    inspectionModel.clear()

                    if (!objectForInspection)
                        return

                    const items = []

                    for (const property in objectForInspection) {
                        const type = typeof objectForInspection[property]

                        if (type === "function") {
                            items.push({
                                name: property,
                                category: "functions",
                                isModel: false,
                                type: type
                            })
                        } else {
                            const value = objectForInspection[property]
                            const detailedType = MonitorUtils.typeName(value)
                            const isModel = Monitor.isModel(value)

                            items.push({
                                name: property,
                                type: detailedType,
                                category: isModel? "models" : "properties",
                                isModel: isModel
                            })
                        }
                    }

                    items.sort((a, b) => {
                        const nameA = a.category
                        const nameB = b.category

                        if (nameA === nameB)
                            return 0

                        if (nameA === "models")
                            return -1

                        if (nameB === "models")
                            return 1

                        if (nameA < nameB)
                            return -1

                        if (nameA > nameB)
                            return 1
                    })

                    inspectionModel.append(items)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5

                    Label {
                        text: name
                        font.pixelSize: 20
                        font.bold: true
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 5
                        clip: true

                        model: ListModel {
                            id: inspectionModel
                        }

                        delegate: Item {
                            implicitWidth: delegateRow.implicitWidth
                            implicitHeight: delegateRow.implicitHeight

                            Row {
                                id: delegateRow

                                readonly property var object: objectForInspection[name]

                                Label {
                                    text: name
                                }

                                Loader {
                                    active: type !== "function"
                                    sourceComponent: Label {
                                        text: ` [${type}]`
                                        color: "darkgreen"
                                    }
                                }

                                Loader {
                                    active: type !== "function"
                                    sourceComponent: Label {
                                        text: ` (${MonitorUtils.valueToString(delegateRow.object)})`
                                        color: "darkred"
                                    }
                                }

                                Loader {
                                    active: isModel
                                    sourceComponent: Label {
                                        text: `, ${delegateRow.object.rowCount()} items`
                                        color: "darkred"
                                        font.bold: true
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (!isModel)
                                        return

                                    const props = {
                                        name: name,
                                        model: objectForInspection[name]
                                    }

                                    inspectionStackView.push(modelInspectionComponent,
                                                             props, StackView.Immediate)
                                }
                            }
                        }

                        section.property: "category"
                        section.delegate: Pane {
                            leftPadding: 0

                            Label {
                                text: section
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        StackView {
            id: inspectionStackView

            SplitView.fillHeight: true
            SplitView.minimumWidth: 100
        }
    }
}

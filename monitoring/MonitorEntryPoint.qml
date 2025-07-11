import QtCore
import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import Monitoring
import AppLayouts.Wallet.stores as WalletStores

import StatusQ.Core
import StatusQ.Core.Theme

Component {
    ColumnLayout {
        spacing: 0

        Settings {
            property alias tabIndex: tabBar.currentIndex
            property alias modelObjectName: objectNameTextFiled.text
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            TabButton {
                text: "Context properties inspection"
            }
            TabButton {
                text: "Models inspection"
            }

            currentIndex: swipeView.currentIndex
        }

        StackLayout {
            id: swipeView

            currentIndex: tabBar.currentIndex
            //anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

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
                                MonitorUtils.contextPropertyBindingHelper(name, this).value

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

                            StatusMouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    inspectionStackView.clear()
                                    headerModel.clear()

                                    const props = {
                                        name: name,
                                        objectForInspection: contextPropertyValue
                                    }

                                    inspectionStackView.push(inspectionList, props)
                                    headerModel.append({ name })
                                }
                            }
                        }
                    }
                }

                Component {
                    id: modelInspectionComponent

                    ModelInspectionPane {}
                }

                Component {
                    id: inspectionList

                    ListView {
                        property var objectForInspection
                        property string name

                        ScrollBar.vertical: ScrollBar {}

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

                        anchors.fill: parent

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

                            StatusMouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (isModel) {
                                        const props = {
                                            name: name,
                                            model: objectForInspection[name]
                                        }

                                        inspectionStackView.push(modelInspectionComponent,
                                                                 props, StackView.Immediate)
                                        headerModel.append({ name })
                                    } else if (type !== "function") {
                                        const props = {
                                            name: name,
                                            objectForInspection: objectForInspection[name]
                                        }

                                        inspectionStackView.push(inspectionList, props, StackView.Immediate)
                                        headerModel.append({ name })
                                    }
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

                Pane {
                    SplitView.fillHeight: true
                    SplitView.minimumWidth: 100

                    ColumnLayout {
                        anchors.fill: parent

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: false

                            RoundButton {
                                text: "⬅️"

                                visible: headerRepeater.count > 1

                                onClicked: {
                                    inspectionStackView.pop(StackView.Immediate)
                                    headerModel.remove(headerModel.count - 1)
                                }
                            }

                            Repeater {
                                id: headerRepeater

                                model: ListModel {
                                    id: headerModel
                                }

                                delegate: TextInput {
                                    readonly property bool last: headerRepeater.count - 1 === index

                                    text: model.name + (last ? "" : "  ->  ")
                                    font.pixelSize: Theme.fontSize20
                                    font.bold: true

                                    selectByMouse: true
                                    readOnly: true
                                }
                            }
                        }

                        MenuSeparator {
                            visible: headerRepeater.count
                            Layout.fillWidth: true
                        }

                        StackView {
                            id: inspectionStackView

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            Pane {
                ColumnLayout {
                    anchors.fill: parent

                    RowLayout {
                        Layout.fillHeight: false
                        Layout.fillWidth: true

                        Label {
                            text: "Model's object name:"
                        }

                        TextField {
                            id: objectNameTextFiled

                            Layout.fillWidth: true

                            selectByMouse: true
                            onAccepted: searchButton.clicked()
                        }

                        Button {
                            id: searchButton

                            text: "Search"

                            onClicked: {
                                const roots = [
                                    applicationWindow,
                                    WalletStores.RootStore
                                ]

                                let obj = null

                                for (let root of roots) {
                                    obj = Monitor.findChild(root, objectNameTextFiled.text)

                                    if (obj)
                                        break
                                }

                                if (!obj) {
                                    objLabel.objStr = "Model not found"
                                    rolesModelContent.model = null
                                    return
                                }

                                if (!Monitor.isModel(obj)) {
                                    objLabel.objStr = "Found object is not a model"
                                    rolesModelContent.model = null
                                    return
                                }

                                objLabel.objStr = obj.toString()
                                rolesModelContent.model = obj
                            }
                        }
                    }

                    Label {
                        id: objLabel

                        property string objStr

                        Layout.fillWidth: true
                        visible: objStr !== ""

                        text: "Object: " + objStr
                    }

                    ModelInspectionPane {
                        id: rolesModelContent

                        showControls: false

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}

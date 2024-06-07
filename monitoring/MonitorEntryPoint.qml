import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Monitoring 1.0
import Qt.labs.settings 1.0

import AppLayouts.Wallet.stores 1.0 as WalletStores
import shared.stores 1.0 as SharedStores

Component {

    ColumnLayout {

        spacing: 0

        Settings {
            property alias tabIndex: tabBar.currentIndex
            property alias modelObjectName: objectNameTextFiled.text
            property alias modelObjectRootName: rootTextField.text
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

                    ModelInspectionPane {}
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

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap

                        text: "Note: 'applicationWindow' is good root object in"
                              + " most cases. 'WalletStores.RootStore' and"
                              + " `SharedStores.RootStore` are also exposed for"
                              + " convenience for models created within those singletons."
                    }

                    RowLayout {
                        Layout.fillHeight: false
                        Layout.fillWidth: true

                        Label {
                            text: "Model's object name:"
                        }

                        TextField {
                            id: objectNameTextFiled

                            selectByMouse: true
                        }

                        Label {
                            text: "Root:"
                        }

                        TextField {
                            id: rootTextField

                            text: "applicationWindow"
                            selectByMouse: true
                        }

                        Button {
                            text: "Search"

                            onClicked: {
                                let rootObj = null

                                try {
                                    rootObj = eval(rootTextField.text)
                                } catch (error) {
                                    objLabel.objStr = "Root object not found!"
                                    return
                                }

                                const obj = Monitor.findChild(
                                              rootObj, objectNameTextFiled.text)

                                objLabel.objStr = obj && Monitor.isModel(obj)
                                        ? obj.toString() : "Model not found!"
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

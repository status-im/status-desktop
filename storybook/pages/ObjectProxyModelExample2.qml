import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtModelsToolkit

Item {
    id: root

    readonly property string intro:
        "This example show how to use ObjectProxyModel in order to overwrite"
        + " the existing role with a value computed from the original role and"
        + " add new role for controlling selection (writable role)."

    ListModel {
        id: srcModel

        ListElement {
            uid: 1
            name: "ETH"
        }
        ListElement {
            uid: 2
            name: "SNT"
        }
        ListElement {
            uid: 3
            name: "DAI"
        }
    }

    ObjectProxyModel {
        id: objectProxy

        delegate: QtObject {
            readonly property string name: "#" + model.name
            property bool selected: true
        }

        expectedRoles: ["name", "uid"]
        exposedRoles: ["name", "selected"]

        sourceModel: srcModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            lineHeight: 1.2
            text: root.intro
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        Button {
            text: "Select all"

            onClicked: {
                const count = objectProxy.rowCount()

                for (let i = 0; i < count; i++)
                    objectProxy.proxyObject(i).selected = true
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: objectProxy

            delegate: CheckBox {
                text: model.name
                checked: model.selected

                onToggled: {
                    objectProxy.proxyObject(model.index).selected = checked
                }
            }
        }
    }
}

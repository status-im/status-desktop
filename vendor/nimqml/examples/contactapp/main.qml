import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    width: 500
    height: 300
    title: "ContactApp"
    visible: true

    menuBar: MenuBar {
        Menu {
            title: "&File"
            MenuItem { text: "&Load"; onTriggered: logic.onLoadTriggered() }
            MenuItem { text: "&Save"; onTriggered: logic.onSaveTriggered() }
            MenuItem { text: "&Exit"; onTriggered: logic.onExitTriggered() }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Component {
            id: tableTextDelegate
            Label {
                id: tableTextDelegateInstance
                property var styleData: undefined
                states: State {
                    when: styleData !== undefined
                    PropertyChanges {
                        target: tableTextDelegateInstance;
                        text: styleData.value;
                        color: styleData.textColor
                    }
                }
            }
        }

        Component {
            id: tableButtonDelegate
            Button {
                id: tableButtonDelegateInstance
                property var styleData: undefined
                text: "Delete"
                onClicked: logic.contactList.del(styleData.row)
            }
        }

        Component {
            id: tableItemDelegate
            Loader {
                id: tableItemDelegateInstance
                sourceComponent: {
                    if (styleData.column === 0 || styleData.column === 1)
                        return tableTextDelegate
                    else if (styleData.column === 2)
                        return tableButtonDelegate
                    else
                        return tableTextDelegate
                }
                Binding {
                    target: tableItemDelegateInstance.item
                    property: "styleData"
                    value: styleData
                }
            }
        }

        TableView {
            model: logic.contactList
            Layout.fillWidth: true
            Layout.fillHeight: true
            TableViewColumn { role: "firstName"; title: "FirstName"; width: 200 }
            TableViewColumn { role: "surname"; title: "LastName"; width: 200}
            TableViewColumn { width: 100; }
            itemDelegate: tableItemDelegate
        }

        RowLayout {
            Label { text: "FirstName" }
            TextField { id: nameTextField; Layout.fillWidth: true; text: "" }
            Label { text: "LastName" }
            TextField { id: surnameTextField; Layout.fillWidth: true; text: "" }
            Button {
                text: "Add"
                onClicked: logic.contactList.add(nameTextField.text, surnameTextField.text)
                enabled: nameTextField.text !== "" && surnameTextField.text !== ""
            }
        }
    }
}

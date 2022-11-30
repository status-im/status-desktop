import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

Item {
    id: root

    property alias model: listView.model

    signal stateChanged(string state)

    ComboBox {
        id: comboBox

        width: parent.width

        model: [Constants.startupState.profileFetching,
            Constants.startupState.profileFetchingSuccess,
            Constants.startupState.profileFetchingTimeout]

        onCurrentIndexChanged: {
            root.stateChanged(model[currentIndex])
        }
    }

    ListView {
        id: listView

        anchors.top: comboBox.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 32

        spacing: 25
        ScrollBar.vertical: ScrollBar { x: root.width }

        delegate: ColumnLayout {
            id: rootDelegate

            width: ListView.view.width

            Label {
                Layout.fillWidth: true
                text: model.entity
                font.weight: Font.Bold
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "loadedMessages:\t"
                }

                SpinBox {
                    editable: true
                    height: 30
                    from: 0; to: model.totalMessages
                    value:  model.loadedMessages
                    onValueChanged: model.loadedMessages = value
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "totalMessages:\t"
                }

                SpinBox {
                    editable: true
                    height: 30
                    from: 0; to: 10 * 1000 * 1000
                    value:  model.totalMessages
                    onValueChanged: model.totalMessages = value
                }
            }
        }
    }
}

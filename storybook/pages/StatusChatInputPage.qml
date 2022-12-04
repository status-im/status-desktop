import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0
import StubDecorators 1.0

import utils 1.0
import shared.status 1.0

SplitView {
    Logs { id: logs }
    SharedRootStoreDecorator { id: rootStoreDecorator }
    UtilsDecorator {id: utilsDecorator }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        //dummy item to position chatInput at the bottom
        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
        }

        StatusChatInput {
            id: chatInput
            property var globalUtils: rootStoreDecorator.globalUtils
            usersStore: QtObject {
                readonly property var usersModel: UsersModel {
                    id: usersModel
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        UsersModelEditor {
            id: modelEditor
            anchors.fill: parent
            model: usersModel

            onRemoveClicked: usersModel.remove(index, 1)
            onRemoveAllClicked: usersModel.clear()
            onAddClicked: usersModel.append(modelEditor.getNewUser(usersModel.count))
        }
    }

    Component.onCompleted: {
        Global.dragArea = this
    }
}

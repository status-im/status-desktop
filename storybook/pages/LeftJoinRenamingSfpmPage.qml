import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtModelsToolkit
import SortFilterProxyModel
import StatusQ.Core.Theme

Control {
    font.pixelSize: Theme.primaryTextFontSize

    ListModel {
        id: leftBaseModel

        Component.onCompleted: {
            const items = []

            for (let i = 0; i < 1000; i++)
                items.push({ name: `base name (${i})`, foreignId: i % 15 })

            append(items)
        }
    }

    ListModel {
        id: rightBaseModel

        Component.onCompleted: {
            const items = []

            for (let i = 0; i < 20; i++)
                items.push({ id: i, name: `foreign name (${i})` })

            append(items)
        }
    }

    RolesRenamingModel {
        id: leftModelRenamed

        sourceModel: leftBaseModel

        mapping: RoleRename {
            from: "name"
            to: "baseName"
        }
    }

    RolesRenamingModel {
        id: rightModelRenamed

        sourceModel: rightBaseModel

        mapping: RoleRename {
            from: "id"
            to: "foreignId"
        }
    }

    LeftJoinModel {
        id: joinModel

        leftModel: leftModelRenamed
        rightModel: rightModelRenamed

        joinRole: "foreignId"
    }

    SortFilterProxyModel {
        id: filteringModel

        sourceModel: joinModel

        filters: ValueFilter {
            roleName: "foreignId"
            value: searchTextField.text

            enabled: searchTextField.length
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            Layout.fillWidth: true

            text: "Simple example showing how to compose custom model from two "
                  + "source models using RolesRenamingModel, LeftJoinModel "
                  + "and SortFilterProxyModel"

            font.bold: true
            wrapMode: Text.Wrap
        }

        TextField {
            id: searchTextField

            Layout.fillWidth: true
            placeholderText: "Filter by foreign id"
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.vertical: ScrollBar {}

            model: filteringModel
            clip: true

            delegate: Label {
                width: ListView.view.height

                text: `${model.baseName}, ${model.name} (id: ${model.foreignId})`
            }
        }
    }
}

// category: Research / Examples

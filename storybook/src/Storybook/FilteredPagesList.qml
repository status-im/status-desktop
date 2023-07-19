import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import SortFilterProxyModel 0.2

import Storybook 1.0

ColumnLayout {
    id: root

    property alias model: filteredModel.sourceModel
    property alias currentPage: pagesList.currentPage

    signal pageSelected(string page)

    SortFilterProxyModel {
        id: filteredModel

        filters: ExpressionFilter {
            enabled: textField.length > 0
            expression: {
                const searchText = textField.text.toLowerCase()
                return model.title.toLowerCase().indexOf(searchText) !== -1
            }
        }
    }

    SectionsDecoratorModel {
        id: sectionsModel

        sourceModel: filteredModel
    }

    RowLayout {
        Layout.fillWidth: true

        TextField {
            id: textField

            Layout.fillWidth: true
            placeholderText: "search"
            selectByMouse: true

            Keys.onEscapePressed: {
                clear()
                focus = false
            }
        }

        ToolButton {
            text: "❌"

            onClicked: textField.clear()
        }
    }

    PagesList {
        id: pagesList

        Layout.fillWidth: true
        Layout.fillHeight: true

        model: sectionsModel

        onPageSelected: root.pageSelected(page)
        onSectionClicked: sectionsModel.flipFolding(index)
    }
}

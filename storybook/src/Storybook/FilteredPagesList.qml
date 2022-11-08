import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import SortFilterProxyModel 0.2

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

    TextField {
        id: textField

        Layout.fillWidth: true
        placeholderText: "search"

        Keys.onEscapePressed: {
            text = ""
            focus = false
        }
    }

    PagesList {
        id: pagesList

        Layout.fillWidth: true
        Layout.fillHeight: true

        model: filteredModel

        onPageSelected: root.pageSelected(page)
    }
}

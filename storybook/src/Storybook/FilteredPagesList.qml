import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import SortFilterProxyModel 0.2

import Storybook 1.0

ColumnLayout {
    id: root

    property alias model: filteredModel.sourceModel
    property alias currentPage: pagesList.currentPage

    signal pageSelected(string page)

    SortFilterProxyModel {
        id: filteredModel

        sorters: [
            ExpressionSorter {
                readonly property string categoryFirst: "_"
                readonly property string categoryUncategorized: "Uncategorized"

                expression: {
                    const catA = modelLeft.category
                    const catB = modelRight.category

                    // Alphabetic order but "_" as a special category goes first
                    if (catA === categoryFirst && catB !== categoryFirst)
                        return true
                    if (catA !== categoryFirst && catB === categoryFirst)
                        return false

                    // and "Uncategorized" goes last
                    if (catA === categoryUncategorized
                            && catB !== categoryUncategorized)
                        return false
                    if (catA !== categoryUncategorized
                            && catB === categoryUncategorized)
                        return true

                    return catA < catB
                }
            },
            StringSorter {
                roleName: "title"
            }
        ]

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

        Component.onCompleted: sectionsModel.sourceModel = filteredModel
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

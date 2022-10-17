import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    property string filterString
    property bool active: true

    enum Mode {
        ShowUnselectedOnly,
        ShowSelectedOnly,
        Highlight
    }
    property int mode: StatusCommunityTags.ShowUnselectedOnly

    property var model
    property alias contentWidth: flow.width

    readonly property int itemsWidth: {
        let result = 0;
        for (let i = 0; i < repeater.count; ++i) {
            result +=  flow.spacing + repeater.itemAt(i).width;
        }
        return result;
    }

    signal clicked(var item)

    implicitWidth: itemsWidth
    implicitHeight: flow.height

    Flow {
        id: flow
        anchors.centerIn: parent
        width: Math.min(parent.width, root.itemsWidth);
        spacing: 10

        Repeater {
            id: repeater

            model: SortFilterProxyModel {
                id: filterModel

                sourceModel: root.model

                function selectionPredicate(selected) {
                    return root.mode === StatusCommunityTags.ShowSelectedOnly ? selected : !selected
                }

                filters: [
                    ExpressionFilter {
                        enabled: root.filterString !== ""
                        expression: {
                            root.filterString
                            return model.name.toUpperCase().indexOf(root.filterString.toUpperCase()) !== -1
                        }
                    },
                    ExpressionFilter {
                        enabled: root.mode !== StatusCommunityTags.Highlight
                        expression: {
                            root.mode
                            return filterModel.selectionPredicate(model.selected)
                        }
                    }
                ]
            }

            delegate: StatusCommunityTag {
                emoji: model.emoji
                name: model.name
                removable: root.mode === StatusCommunityTags.ShowSelectedOnly && root.active
                highlighted: root.mode === StatusCommunityTags.Highlight && model.selected

                onClicked: root.clicked(model)
            }
        }
    }
}

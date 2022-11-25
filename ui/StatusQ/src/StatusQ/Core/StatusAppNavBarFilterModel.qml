import QtQuick 2.13
import QtQml.Models 2.13

DelegateModel {
    id: root

    property var filterAcceptsItem: function(item) { return true; }

    signal aboutToUpdateFilteredModel()

    function update() {
        root.aboutToUpdateFilteredModel()

        if (root.items.count > 0) {
            root.items.setGroups(0, root.items.count, "items");
        }

        var visible = [];
        for (var i = 0; i < root.items.count; ++i) {
            var item = root.items.get(i);
            if (filterAcceptsItem(item.model)) {
                visible.push(item);
            }
        }

        for (i = 0; i < visible.length; ++i) {
            var item = visible[i];
            item.inVisible = true;
            if (item.visibleIndex !== i) {
                visibleItems.move(item.visibleIndex, i, 1);
            }
        }
    }

    items.onChanged: update()
    onFilterAcceptsItemChanged: update()

    groups: DelegateModelGroup {
        id: visibleItems

        name: "visible"
        includeByDefault: false
    }

    filterOnGroup: "visible"
}

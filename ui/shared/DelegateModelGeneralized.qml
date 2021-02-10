import QtQuick 2.13
import QtQml.Models 2.3
import "../imports"

DelegateModel {
    id: delegateModel
    property var lessThan

    property int sortOrder: 0
    onSortOrderChanged: items.setGroups(0, items.count, "unsorted")

    function insertPosition(lessThan, item) {
        var lower = 0
        var upper = items.count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower) / 2)
            var result = lessThan(item.model, items.get(middle).model);
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort(lessThan) {
        while (unsortedItems.count > 0) {
            var item = unsortedItems.get(0)
            var index = insertPosition(lessThan, item)

            item.groups = "items"
            items.move(item.itemsIndex, index)
        }
    }

    items.includeByDefault: false
    groups: DelegateModelGroup {
        id: unsortedItems
        name: "unsorted"

        includeByDefault: true
        onChanged: {
            if (delegateModel.sortOrder === delegateModel.lessThan.length)
                setGroups(0, count, "items")
            else
                delegateModel.sort(delegateModel.lessThan[delegateModel.sortOrder])
        }
    }
}

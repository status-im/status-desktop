import QtQuick 2.13
import utils 1.0

Item {
    id: suggestionsPanelRoot
    property alias model: filterModel

    property string formattedFilter
    property var sourceModel
    property string filter: ""
    property int cursorPosition: 0
    property int lastAtPosition: 0
    property var property: ([])

    onFilterChanged: invalidateFilter()
    onPropertyChanged: invalidateFilter()
    onSourceModelChanged: invalidateFilter()
    Component.onCompleted: invalidateFilter()

    ListView {
        // This is a fake list (invisible), used just for the sake of accessing items of the `sourceModel`
        // without exposing explicit methods from the model which would return item detail.
        // In general the whole thing about preparing/displaying suggestion panel and list there should
        // be handled in a much better way, at least using `ListView` and `DelegateModel` which will
        // filter out the list instead doing all that manually here.
        id: sourceModelList
        visible: false
        model: suggestionsPanelRoot.sourceModel
        delegate: Item {
            property string publicKey: model.id
            property string name: model.name
            property string icon: model.icon
            property bool isIdenticon: model.isIdenticon
        }
    }

    ListModel {
        id: filterModel
    }

    function invalidateFilter() {
        filterModel.clear()

        if (!isFilteringPropertyOk())
            return

        let filter = getFilter()
        if (filter === undefined)
            return

        this.lastAtPosition = -1
        for (let c = cursorPosition; c >= 0; c--) {
            if (filter.charAt(c) === "@") {
                this.lastAtPosition = c
                break
            }
        }
        if (this.lastAtPosition === -1)
            return

        const all = shouldShowAll(filter)

        for (var i = 0; i < sourceModelList.count; ++i) {
            let listItem = sourceModelList.itemAtIndex(i)
            const item = {
                publicKey: listItem.publicKey,
                name: listItem.name,
                icon: listItem.icon,
                isIdenticon: listItem.isIdenticon
            }
            if (all || isAcceptedItem(filter, item)) {
                filterModel.append(item)
            }
        }
    }

    function getFilter() {
        if (this.filter.length === 0 || this.cursorPosition === 0) {
            return
        }

        return globalUtils.plainText(this.filter)
    }

    function shouldShowAll(filter) {
        var cursorAtEnd = this.cursorPosition === filter.length;
        var hasAtBeforeCursor = filter.charAt(this.cursorPosition - 1) === "@" 
        var hasWhiteSpaceBeforeAt = filter.charAt(this.cursorPosition - 2) === " " || filter.charAt(this.cursorPosition - 2) === "\n"
        var hasWhiteSpaceAfterAt = filter.charAt(this.cursorPosition) === " "

        if (filter === "@" ||
                (hasAtBeforeCursor && hasWhiteSpaceBeforeAt && hasWhiteSpaceAfterAt) ||
                (this.cursorPosition === 1 && hasAtBeforeCursor && hasWhiteSpaceAfterAt) ||
                (cursorAtEnd && filter.endsWith("@") && hasWhiteSpaceBeforeAt)) {
            return true
        }

        return false
    }

    function isAcceptedItem(filter, item) {
        let properties = this.property.filter(p => !!item[p])
        if (properties.length === 0) {
            return false
        }
        
        let filterWithoutAt = filter.substring(this.lastAtPosition + 1, this.cursorPosition)
        filterWithoutAt = filterWithoutAt.replace(/\*/g, "")
        suggestionsPanelRoot.formattedFilter = filterWithoutAt

        return !properties.every(p => item[p].toLowerCase().match(filterWithoutAt.toLowerCase()) === null)
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property.length === 0) {
            return false
        }
        return true
    }
}

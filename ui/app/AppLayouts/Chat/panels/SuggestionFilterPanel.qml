import QtQuick 2.13
import utils 1.0

import StatusQ.Core 0.1

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

    StatusListView {
        // This is a fake list (invisible), used just for the sake of accessing items of the `sourceModel`
        // without exposing explicit methods from the model which would return item detail.
        // In general the whole thing about preparing/displaying suggestion panel and list there should
        // be handled in a much better way, at least using `ListView` and `DelegateModel` which will
        // filter out the list instead doing all that manually here.
        id: sourceModelList
        visible: false
        model: suggestionsPanelRoot.sourceModel
        delegate: Item {
            property string publicKey: model.pubKey
            property string name: model.displayName
            property string nickname: model.localNickname
            property string alias: model.alias
            property string ensName: model.ensName
            property string icon: model.icon
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
        if (filter === undefined) {
            formattedFilter = ""
            return
        }

        this.lastAtPosition = -1
        for (let c = cursorPosition === 0 ? 0 : (cursorPosition-1); c >= 0; c--) {
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
                name: listItem.name || listItem.alias,
                nickname: listItem.nickname,
                ensName: listItem.ensName,
                icon: listItem.icon
            }
            if (all || isAcceptedItem(filter, item)) {
                filterModel.append(item)
            }
        }

        const everyoneItem = {
            publicKey: "0x00001",
            name: "everyone",
            icon: ""
        }
        if (all || isAcceptedItem(filter, everyoneItem)) {
            filterModel.append(everyoneItem)
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

        return properties.some(p => item[p].toLowerCase().match(filterWithoutAt.toLowerCase()) != null)
               && (lastAtPosition > -1)
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property.length === 0) {
            return false
        }
        return true
    }
}

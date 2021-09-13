import QtQuick 2.13


Item {
    id: component
    property alias model: filterModel

    property string formattedFilter
    property QtObject sourceModel: undefined
    property string filter: ""
    property int cursorPosition: 0
    property int lastAtPosition: 0
    property var property: ([])

    Connections {
        function onFilterChanged(){
            invalidateFilter()
        }
        function onPropertyChanged() {
            invalidateFilter()
        }
        function onSourceModelChanged() {
            invalidateFilter()
        }
    }

    Component.onCompleted: invalidateFilter()

    ListModel {
        id: filterModel
    }

    function invalidateFilter() {
        filterModel.clear();     

        if (!isFilteringPropertyOk())
            return

        var filter = getFilter()
        if (!isFilterReady(filter))
            return

        const all = shouldShowAll(filter)

        for (var i = 0; i < sourceModel.rowCount(); ++i) {
            const publicKey = sourceModel.rowData(i, "publicKey");
            const item = {
                alias: sourceModel.rowData(i, "alias"),
                userName: sourceModel.rowData(i, "userName"),
                publicKey: publicKey,
                identicon: getProfileImage(publicKey, false, false) || sourceModel.rowData(i, "identicon"),
                localName: sourceModel.rowData(i, "localName")
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

        return chatsModel.plainText(this.filter)
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
            this.lastAtPosition = this.cursorPosition - 1;
            return true
        }

        return false
    }

    function isFilterReady(filter) {
        if (filter === undefined) {
            return false
        }

        // Prevents suggestions to show up at all
        if (filter.indexOf("@") === -1)  {
          return false
        }

        let hasWhiteSpaceBeforeCursor = filter.charAt(this.cursorPosition - 1) === " "

        if (filter.charAt(this.cursorPosition - 2) === "@" && hasWhiteSpaceBeforeCursor) {
            return false
        }

        return true
    }

    function isAcceptedItem(filter, item) {
        let properties = this.property
            .filter(p => !!item[p])

        if (properties.length === 0) {
            return false
        }
        
        let filterWithoutAt = filter.substring(lastAtPosition + 1, this.cursorPosition)
        filterWithoutAt = filterWithoutAt.replace(/\*/g, "")
        component.formattedFilter = filterWithoutAt

        return !properties.every(p => item[p].toLowerCase().match(filterWithoutAt.toLowerCase()) === null)
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property.length === 0) {
            return false
        }
        return true
    }
}

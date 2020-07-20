import QtQuick 2.13

Item {
    id: component
    property alias model: filterModel

    property QtObject sourceModel: undefined
    property string filter: ""
    property int cursorPosition: 0
    property int lastAtPosition: 0
    property string property: ""

    Connections {
        onFilterChanged: invalidateFilter()
        onPropertyChanged: invalidateFilter()
        onSourceModelChanged: invalidateFilter()
    }

    Component.onCompleted: invalidateFilter()

    ListModel {
        id: filterModel
    }

    function invalidateFilter() {
        if (sourceModel === undefined)
            return;

        filterModel.clear();

        if (!isFilteringPropertyOk())
            return

        var length = sourceModel.count
        for (var i = 0; i < length; ++i) {
            var item = sourceModel.get(i);
            if (isAcceptedItem(item)) {
                filterModel.append(item)
            }
        }
    }

    function isAcceptedItem(item) {
        let properties = this.property.split(",")
            .map(p => p.trim())
            .filter(p => !!item[p])

        if (properties.length === 0 || this.filter.length === 0 || this.cursorPosition === 0) {
            return false
        }

        // Prevents suggestions to show up at all
        if (this.filter.indexOf("@") === -1)  {
          return false
        }

        let cursorAtEnd = this.cursorPosition === this.filter.length;
        let hasAtBeforeCursor = this.filter.charAt(this.cursorPosition - 1) === "@" 
        let hasWhiteSpaceBeforeAt = this.filter.charAt(this.cursorPosition - 2) === " "
        let hasWhiteSpaceAfterAt = this.filter.charAt(this.cursorPosition) === " "
        let hasWhiteSpaceBeforeCursor = this.filter.charAt(this.cursorPosition - 1) === " "

        if (this.filter.charAt(this.cursorPosition - 2) === "@" && hasWhiteSpaceBeforeCursor) {
          return false
        }

        if (this.filter === "@" ||
          (hasAtBeforeCursor && hasWhiteSpaceBeforeAt && hasWhiteSpaceAfterAt) ||
          (this.cursorPosition === 1 && hasAtBeforeCursor && hasWhiteSpaceAfterAt) ||
          (cursorAtEnd && this.filter.endsWith("@") && hasWhiteSpaceBeforeAt)) {
          this.lastAtPosition = this.cursorPosition - 1;
          return true
        }

        let filterWithoutAt = this.filter.substring(lastAtPosition + 1, this.cursorPosition)

        return !properties.every(p => item[p].toLowerCase().match(filterWithoutAt.toLowerCase()) === null)
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property === "") {
            return false
        }
        return true
    }
}

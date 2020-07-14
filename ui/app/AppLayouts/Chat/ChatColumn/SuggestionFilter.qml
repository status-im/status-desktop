import QtQuick 2.13

Item {
    id: component
    property alias model: filterModel

    property QtObject sourceModel: undefined
    property string filter: ""
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

        if (properties.length == 0) {
            return false
        }

        if (this.filter.endsWith("@")) {
            return true
        }

        let lastAt = this.filter.lastIndexOf("@")

        if (lastAt == -1) {
            return false
        }

        let filterWithoutAt = this.filter.substring(lastAt+1)

        if (filterWithoutAt == "") {
            return true
        }

        return !properties.every(p => item[p].toLowerCase().match(filterWithoutAt.toLowerCase()) == null)
    }

    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property === "") {
            return false
        }
        return true
    }
}




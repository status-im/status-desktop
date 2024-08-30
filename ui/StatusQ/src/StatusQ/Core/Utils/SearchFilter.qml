import SortFilterProxyModel 0.2

RegExpFilter {
    required property string searchPhrase

    pattern: `*${searchPhrase}*`
    caseSensitivity: Qt.CaseInsensitive
    syntax: RegExpFilter.Wildcard
}

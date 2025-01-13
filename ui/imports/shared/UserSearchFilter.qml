import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

AnyOf {
    id: root

    property string searchString

    enabled: root.searchString !== ""

    // substring search for either nickname or the other primary/secondary display name
    SearchFilter {
        roleName: "localNickname"
        searchPhrase: root.searchString
    }

    SearchFilter {
        roleName: "preferredDisplayName"
        searchPhrase: root.searchString
    }

    // exact search for the full key
    ValueFilter {
        roleName: "compressedPubKey"
        value: root.searchString
    }
}

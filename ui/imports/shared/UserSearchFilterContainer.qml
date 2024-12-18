import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import SortFilterProxyModel 0.2

AnyOf {
    id: root

    property string searchString

    function searchPredicate(ensName, displayName, aliasName) {
        const lowerCaseSearchString = root.searchString.toLowerCase()
        const secondaryName = ProfileUtils.displayName("", ensName, displayName, aliasName)

        return secondaryName.toLowerCase().includes(lowerCaseSearchString)
    }

    enabled: root.searchString !== ""

    // substring search for either nickname or the other primary/secondary display name
    SearchFilter {
        roleName: "localNickname"
        searchPhrase: root.searchString
    }
    FastExpressionFilter {
        expression: {
            root.searchString
            return root.searchPredicate(model.ensName, model.displayName, model.alias)
        }
        expectedRoles: ["ensName", "displayName", "alias"]
    }
    // exact search for the full key
    ValueFilter {
        roleName: "compressedPubKey"
        value: root.searchString
    }
}

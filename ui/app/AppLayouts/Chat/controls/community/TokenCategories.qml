pragma Singleton

import QtQml 2.15

QtObject {
    enum Category {
        Community, Own, General
    }

    function getCategoryLabelForAsset(category) {
        switch (category) {
            case TokenCategories.Category.Community:
                return qsTr("Community assets")
            case TokenCategories.Category.Own:
                return qsTr("Your assets")
            case TokenCategories.Category.General:
                return qsTr("All listed assets")
        }

        return ""
    }

    function getCategoryLabelForCollectible(category) {
        switch (category) {
            case TokenCategories.Category.Community:
                return qsTr("Community collectibles")
            case TokenCategories.Category.Own:
                return qsTr("Your collectibles")
            case TokenCategories.Category.General:
                return qsTr("All collectibles")
        }

        return ""
    }
}

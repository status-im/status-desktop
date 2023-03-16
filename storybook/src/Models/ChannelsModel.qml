import QtQuick 2.15

ListModel {
    ListElement {
        itemId: "_welcome"
        isCategory: false
        categoryId: ""
        name: "welcome"
        emoji: ""
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: "_announcements"
        isCategory: false
        categoryId: ""
        name: "announcements"
        emoji: ""
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: ""
        isCategory: true
        categoryId: "_discussion"
        name: "discussion"
        emoji: ""
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: "_general"
        isCategory: false
        categoryId: "_discussion"
        name: "general"
        emoji: "👋"
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: "_help"
        isCategory: false
        categoryId: "_discussion"
        name: "help"
        emoji: "⚽"
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: ""
        isCategory: true
        categoryId: "_support"
        name: "support"
        emoji: ""
        color: ""
        icon: ""
        colorId: 1
    }
    ListElement {
        itemId: "_faq"
        isCategory: false
        categoryId: "_support"
        name: "faq"
        emoji: ""
        color: ""
        icon: ""
        colorId: 5
    }
    ListElement {
        itemId: "_report-scam"
        isCategory: false
        categoryId: "_support"
        name: "report-scam"
        emoji: ""
        color: ""
        icon: ""
        colorId: 4
    }
    ListElement {
        itemId: ""
        isCategory: true
        categoryId: "_faq"
        name: "faq"
        emoji: ""
        color: ""
        icon: ""
        colorId: 5
    }
}

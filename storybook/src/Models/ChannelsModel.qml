import QtQuick 2.14

ListModel {
    ListElement {
        itemId: "1"
        isCategory: false
        categoryId: ""
        name: "welcome"
        emoji: ""
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "2"
        isCategory: false
        categoryId: ""
        name: "announcements"
        emoji: ""
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "0"
        isCategory: true
        categoryId: "1"
        name: "discussion"
        emoji: ""
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "3"
        isCategory: false
        categoryId: "1"
        name: "general"
        emoji: "👋"
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "4"
        isCategory: false
        categoryId: "1"
        name: "help"
        emoji: "⚽"
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "0"
        isCategory: true
        categoryId: "2"
        name: "support"
        emoji: ""
        color: ""
        colorId: 1
    }
    ListElement {
        itemId: "5"
        isCategory: false
        categoryId: "2"
        name: "faq"
        emoji: ""
        color: ""
        colorId: 5
    }
    ListElement {
        itemId: "6"
        isCategory: false
        categoryId: "2"
        name: "report-scam"
        emoji: ""
        color: ""
        colorId: 4
    }
    ListElement {
        itemId: "0"
        isCategory: true
        categoryId: "3"
        name: "faq"
        emoji: ""
        color: ""
        colorId: 5
    }
}

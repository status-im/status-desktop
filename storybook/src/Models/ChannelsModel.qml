import QtQuick 2.14

ListModel {
    ListElement {
        itemId: 0
        name: "welcome"
        isCategory: false
        color: ""
        colorId: 1
        icon: ""
    }
    ListElement {
        itemId: 1
        name: "announcements"
        isCategory: false
        color: ""
        colorId: 1
        icon: ""
    }
    ListElement {
        name: "Discussion"
        isCategory: true

        subItems: [
            ListElement {
                itemId: 2
                name: "general"
                icon: ""
                emoji: "👋"
            },
            ListElement {
                itemId: 3
                name: "help"
                icon: ""
                color: ""
                colorId: 1
                emoji: "⚽"
            }
        ]
    }
    ListElement {
        name: "Support"
        isCategory: true

        subItems: [
            ListElement {
                itemId: 4
                name: "faq"
                icon: ""
                color: ""
                colorId: 5
            },
            ListElement {
                itemId: 5
                name: "report-scam"
                icon: ""
                color: ""
                colorId: 4
            }
        ]
    }
    ListElement {
        name: "Empty"
        isCategory: true
        subItems: []
    }
}

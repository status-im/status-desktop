import QtQuick

ListModel {
    id: root

    Component.onCompleted: {
        var englishWords = [
            "age", "agent", "apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape", "horse", "icecream", "jellyfish",
            "kiwi", "lemon", "mango", "nut", "orange", "pear", "quail", "rabbit", "strawberry", "turtle",
            "umbrella", "violet", "watermelon", "xylophone", "yogurt", "zebra"
            // Add more English words here...
        ];

        for (var i = 0; i < englishWords.length; i++) {
            root.append({ seedWord: englishWords[i] });
        }
    }
}

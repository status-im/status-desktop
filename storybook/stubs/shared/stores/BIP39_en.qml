import QtQuick 2.13

ListModel {
    id: root

    Component.onCompleted: {
        var englishWords = [
            "apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape", "horse", "ice cream", "jellyfish",
            "kiwi", "lemon", "mango", "nut", "orange", "pear", "quail", "rabbit", "strawberry", "turtle",
            "umbrella", "violet", "watermelon", "xylophone", "yogurt", "zebra"
            // Add more English words here...
        ];

        for (var i = 0; i < englishWords.length; i++) {
            root.append({ seedWord: englishWords[i] });
        }
    }
}

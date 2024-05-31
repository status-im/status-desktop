import QtQuick 2.15

/// Data model that holds a queue of SessionRequestResolved events as they are received from the SDK
ListModel {
    id: root

    function enqueue(event) {
        root.append(event);
    }

    function dequeue() {
        if (root.count > 0) {
            var item = root.get(0);
            root.remove(0);
            return item;
        }
        return null;
    }
}

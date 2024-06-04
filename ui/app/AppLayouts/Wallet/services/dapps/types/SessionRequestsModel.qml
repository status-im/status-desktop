import QtQuick 2.15

/// Data model that holds a queue of SessionRequestResolved events as they are received from the SDK
ListModel {
    id: root

    function enqueue(request) {
        root.append(request);
    }

    function dequeue() {
        if (root.count > 0) {
            var item = root.get(0);
            root.remove(0);
            return item;
        }
        return null;
    }

    /// returns null if not found
    function findRequest(topic, id) {
        for (var i = 0; i < root.count; i++) {
            let entry = root.get(i)
            if (entry.topic === topic && entry.id === id) {
                return entry;
            }
        }
        return null;
    }
}

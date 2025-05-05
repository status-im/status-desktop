import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

Instantiator {
    id: root

    property Menu menu

    onObjectAdded: function(index, object) {
        if (object instanceof Menu)
            menu.addMenu(object)
        else if (object instanceof Action)
            menu.addAction(object)
        else
            menu.addItem(object)
    }

    onObjectRemoved: function(index, object) {
        if (object instanceof Menu)
            menu.removeMenu(object)
        else if (object instanceof Action)
            menu.removeAction(object)
        else
            menu.removeItem(object)
    }
}

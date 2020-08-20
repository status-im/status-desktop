import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

StackView {
    id: root
    default property list<FormGroup> groups
    property int currentIdx: 0
    property bool isLastGroup: currentIdx === groups.length - 1
    property bool isFirstGroup: currentIdx === 0
    signal groupActivated(Item group)
    property alias currentGroup: root.currentItem
    property var next: function() {
        if (groups && groups.length <= currentIdx + 1) {
            return
        }
        const group = groups[++currentIdx]
        this.push(group, StackView.Immediate)

    }
    property var back: function() {
        if (currentIdx <= 0) {
            return
        }
        this.pop()
        currentIdx--
    }

    function reset() {
        for (let i=0; i<groups.length; i++) {
            groups[i].reset()
        }
        this.pop(null)
        currentIdx = 0
    }

    initialItem: groups[currentIdx]
    anchors.fill: parent

    // The below transitions are pointless, but without them,
    // the final input in the final TransactionFormGroup will
    // not be able to receive focus! Seems like a Qt bug...
    pushEnter: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1
            to:1
            duration: 1
        }
    }
    pushExit: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1
            to:1
            duration: 1
        }
    }
    popEnter: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1
            to:1
            duration: 1
        }
    }
    popExit: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1
            to:1
            duration: 1
        }
    }
}

import QtQuick 2.14
import QtQuick.Controls 2.14

QtObject {
    id: root

    required property StackView stackView

    readonly property StatesStack _statesStack: StatesStack { id: statesStack }

    property alias currentState: statesStack.currentState
    property alias size: statesStack.size
    readonly property alias states: statesStack.states

    function pushInitialState(state) {
        if(size > 0)
            console.warn("Pushing initial state but the stack already contains elements:  " + size)
        statesStack.push(state)
    }

    function push(state, item, properties, operation) {
        // States related operations:
        statesStack.push(state)

        // Stack view related operations:
        return stackView.push(item, properties, operation)
    }

    function pop(operation) {
        // States related operations:
        statesStack.pop()

        // Stack view related operations:
        return stackView.pop(operation)
    }

    function clear(initialState, operation) {
        // States related operations:
        statesStack.clear()
        statesStack.push(initialState)

        // Stack view related operations:
        return stackView.pop(null, operation) // Resetting to the initial stack state
    }
}

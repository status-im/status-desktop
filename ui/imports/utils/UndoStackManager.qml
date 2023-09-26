import QtQuick 2.15

/*
    Custom stack-based undo/redo implementation for TextEdit that works with formatted text.
    
    Usage:
        TextEdit {
            id: textEdit
            text: "Hello world"
            onCustomEvent: undoStack.clear()
        }

        UndoRedoStack {
            id: undoStack
            textEdit: textEdit
            enabled: true
            maxStackSize: 100
        }
*/

Item {
    id: root

    /*
        The TextEdit to apply undo/redo to. The stack manager will be installed automatically on this textEdit
    */
    required property TextEdit textEdit
    /*
        The maximum stack size
        Once the maximum stack size is reached, the stack will be reduced to half its size by removing every second item
        As a result the undo/redo will be less precise, jumping back/forward by 2 steps instead of 1
        The first item in the stack will always be kept
    */
    property int maxStackSize: 100
    /*
        Function used to clear the stack
        This function will be called automatically when the TextEdit component changes or when the enabled property changes
    */
    function clear() {
        d.undoStack = []
        d.redoStack = []
        d.previousFormattedText = ""
        d.previousText = ""
    }

    /*
        Undo the last action
        count: The number of actions to redo
    */
    function undo(count = 1) {
        if(d.undoStack.length == 0 || count <= 0) {
            return
        }

        for (var i = 0; i < count; i++) {
            if(d.undoStack.length == 0) {
                return
            }

            const lastAction = d.undoStack.pop()
            d.redoStack.push(lastAction)
            lastAction.undo()
        }
    }

    /*
        Redo the last action
        count: The number of actions to redo
    */
    function redo(count = 1) {
        if(d.redoStack.length == 0 || count <= 0) {
            return
        }

        for (var i = 0; i < count; i++) {
            if(d.redoStack.length == 0) {
                return
            }
            const lastAction = d.redoStack.pop()
            d.undoStack.push(lastAction)    
            lastAction.redo()
        }
    }
    
    onTextEditChanged: {
        clear()
        textEdit.Keys.forwardTo.push(root)
    }
    onEnabledChanged: clear()

    Keys.enabled: root.enabled
    Keys.onPressed: {
        if(event.matches(StandardKey.Undo)) {
            undo(event.isAutoRepeat ? 2 : 1)
            event.accepted = true
            return
        }
        
        if(event.matches(StandardKey.Redo)) {
            redo(event.isAutoRepeat ? 2 : 1)
            event.accepted = true
            return
        }
    }

    readonly property QtObject d: QtObject {
        property var undoStack: []
        property var redoStack: []
        property string previousFormattedText: ""
        property string previousText: ""

        property bool aboutToChangeText: false

        function reduceUndoStack() {
            if(d.undoStack.length <= root.maxStackSize) {
                return
            }

            const newStackSize = Math.ceil(root.maxStackSize / 2)
            print("Reducing undo stack to " + newStackSize + " items")
            for(var i = 1; i <= newStackSize; i++) {
                print("Removing " + Math.ceil(root.maxStackSize / newStackSize) + " items from index " + i)
                d.undoStack.splice(i, Math.ceil(root.maxStackSize / newStackSize))
            }
        }

        readonly property Connections textChangedConnection: Connections {
            target: root.textEdit
            enabled: root.enabled && !d.aboutToChangeText
            function onTextChanged() {
                const unformattedText = root.textEdit.getText(0, root.textEdit.length)
                if(d.previousText !== unformattedText) {
                    const newFormattedText = root.textEdit.text
                    const previousFormattedTextCopy = d.previousFormattedText
                    d.undoStack.push({
                        undo: function() {
                            d.aboutToChangeText = true
                            root.textEdit.text = previousFormattedTextCopy
                            root.textEdit.cursorPosition = root.textEdit.length
                            d.aboutToChangeText = false
                        },
                        redo: function() {
                            d.aboutToChangeText = true
                            root.textEdit.text = newFormattedText
                            root.textEdit.cursorPosition = root.textEdit.length
                            d.aboutToChangeText = false
                        }
                    })

                    d.reduceUndoStack()

                    d.previousText = unformattedText
                    d.previousFormattedText = newFormattedText
                }
            }
        }
    }
}

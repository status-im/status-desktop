import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    id: root
    property var isValid: true
    property var validate: function() {
        let isValid = true
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            if (component.hasOwnProperty("validate") && typeof component.validate === "function") {
                isValid = component.validate()
            }
        }
        root.isValid = isValid
        return isValid
    }
    color: Style.current.background
    function reset() {
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            try {
                if (component.hasOwnProperty("resetInternal") && typeof component.resetInternal === "function") {
                    component.resetInternal()
                }
                if (component.hasOwnProperty("reset") && typeof component.reset === "function") {
                    component.reset()
                }
            } catch (e) {
                console.warn("Error resetting component", i, ":", e.message)
                continue
            }
        }
    }
    StackView.onActivated: {
        // parent refers to the StackView
        parent.groupActivated(this)
    }
    Component.onCompleted: {
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            if (component.hasOwnProperty("isValid")) {
                component.isValidChanged.connect(updateGroupValidity)
                root.isValid = root.isValid && component.isValid // set the initial state
            }
        }
    }
    function updateGroupValidity() {
        let isValid = true
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            if (component.hasOwnProperty("isValid")) {
                isValid = isValid && component.isValid
            }
        }
        root.isValid = isValid
    }
}
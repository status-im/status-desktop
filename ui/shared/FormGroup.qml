import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    id: root
    property var isValid: true
    property var isPending: false
    property var validate: function() {
        let isValid = true
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            if (component.hasOwnProperty("validate") && typeof component.validate === "function") {
                isValid = component.validate()
            }
            if (component.hasOwnProperty("isPending")) {
                isPending = component.isPending
            }
        }
        root.isValid = isValid
        root.isPending = isPending
        return { isValid, isPending }
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
                component.isValidChanged.connect(updateGroupValidityAndPendingStatus)
                root.isValid = root.isValid && component.isValid // set the initial state
            }
            if (component.hasOwnProperty("isPending")) {
                component.isPendingChanged.connect(updateGroupValidityAndPendingStatus)
                root.isPending = component.isPending
            }
        }
    }
    function updateGroupValidityAndPendingStatus() {
        let isValid = true
        let isPending = false
        for (let i=0; i<children.length; i++) {
            const component = children[i]
            if (component.hasOwnProperty("isValid")) {
                isValid = isValid && component.isValid
            }
            if (component.hasOwnProperty("isPending")) {
                isPending = component.isPending
            }
        }
        root.isValid = isValid
        root.isPending = isPending
    }
}

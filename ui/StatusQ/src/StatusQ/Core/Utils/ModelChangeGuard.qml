import QtQml 2.15

ModelChangeTracker {
    enabled: false

    onRevisionChanged: {
        throw new Error("The model is assumed to be immutable.")
    }
}

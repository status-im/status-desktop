import QtQml

ModelChangeTracker {
    enabled: false

    onRevisionChanged: {
        throw new Error("The model is assumed to be immutable.")
    }
}

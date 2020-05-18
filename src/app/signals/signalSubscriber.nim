type SignalSubscriber* = ref object of RootObj

# Override this method
method onSignal*(self: SignalSubscriber, signal: string) {.base.} =
  echo "Received a signal: ", signal  # TODO: log signal received
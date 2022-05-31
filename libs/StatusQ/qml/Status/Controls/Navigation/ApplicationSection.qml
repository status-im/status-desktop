import QtQml

/*!
  An application section with button and content view
  */
QtObject {
    required property NavigationBarButtonComponent navButton
    required property ApplicationContentView content

    component NavigationBarButtonComponent: NavigationBarButton {}
    component ApplicationContentViewComponent: ApplicationContentView {}
}

from .object import NativeObject


class Button(NativeObject):

    def click(self):
        self.object.Press()

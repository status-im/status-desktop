import squish

from .base_element import BaseElement


class List(BaseElement):

    @property
    def items(self):
        return [self.object.itemAtIndex(index) for index in range(self.object.count)]

    def select(self, attribute_value: str, attribute_name: str = 'text'):
        for index in range(self.object.count):
            list_item = self.object.itemAt(index)
            if str(getattr(list_item, attribute_value, '')) == attribute_name:
                squish.mouseClick(list_item)
                return
        raise LookupError(f'List item: {attribute_value}:{attribute_name} not found in {self.items}')

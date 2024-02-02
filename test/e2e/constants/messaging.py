from enum import Enum


class Messaging(Enum):
    WELCOME_GROUP_MESSAGE = "Welcome to the beginning of the "
    CONTACT_REQUEST_SENT = 'Contact Request Sent'
    NO_FRIENDS_ITEM = 'You don’t have any contacts yet'
    NEW_CONTACT_REQUEST = 'New Contact Request'
    MESSAGE_NOTE_IDENTITY_REQUEST = 'Ask a question that only the real athletic will be able to answer e.g. a question about a shared experience, or ask athletic to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).'
    YOU_NEED_TO_BE_A_MEMBER = 'You need to be a member of this group to send messages'
    
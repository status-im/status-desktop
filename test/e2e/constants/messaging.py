from enum import Enum


class Messaging(Enum):
    WELCOME_GROUP_MESSAGE = "Welcome to the beginning of the "
    CONTACT_REQUEST_SENT = 'Contact Request Sent'
    NO_FRIENDS_ITEM = 'You don’t have any contacts yet'
    NEW_CONTACT_REQUEST = 'New Contact Request'
    MESSAGE_NOTE_IDENTITY_REQUEST = 'Ask a question only they can answer'
    YOU_NEED_TO_BE_A_MEMBER = 'You need to be a member of this group to send messages'
    ID_VERIFICATION_REQUEST_SENT = 'ID verification request sent'
    ID_VERIFICATION_REPLY_SENT = 'ID verification reply sent'

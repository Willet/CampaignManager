from flask.ext.login import UserMixin


class User(UserMixin):
    def __init__(self, user_id):
        self.id = user_id

    @classmethod
    def authenticate(cls, username, password):
        user = None

        if user:
            authenticated = False #user.check_password
        else:
            authenticated = False

        return user, authenticated


    @classmethod
    def get_by_id(cls, id):
        return None
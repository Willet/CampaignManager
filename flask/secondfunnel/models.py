from flask.ext.login import UserMixin


class User(UserMixin):
    def __init__(self, user_id):
        self.id = user_id

    @classmethod
    def get(cls, id):
        return cls('nterwoord')
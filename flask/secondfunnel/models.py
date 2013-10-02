from flask.ext.login import UserMixin
from sqlalchemy import Column
from sqlalchemy.ext.hybrid import hybrid_property
from werkzeug.security import generate_password_hash, check_password_hash
from .extensions import db

STRING_LEN = 64


class User(db.Model, UserMixin):
    __tablename__ = 'users'

    id = Column(db.Integer, primary_key=True)
    username = Column(db.String(STRING_LEN), nullable=False, unique=True)
    email = Column(db.String(STRING_LEN))
    _password = Column('password', db.String(STRING_LEN), nullable=False)

    @hybrid_property
    def password(self):
        return self._password

    @password.setter
    def set_password(self, password):
        self._password = generate_password_hash(password)

    def check_password(self, password):
        if self.password is None:
            return False
        return check_password_hash(self.password, password)

    @classmethod
    def authenticate(cls, username, password):
        user = cls.query.filter(User.username == username).first()

        if user:
            authenticated = user.check_password(password)
        else:
            authenticated = False

        return user, authenticated


    @classmethod
    def get_by_id(cls, id):
        return cls.query.filter_by(id=id).first_or_404()
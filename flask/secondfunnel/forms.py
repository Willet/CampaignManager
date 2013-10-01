from flask.ext.wtf import Form
from wtforms import TextField, PasswordField
from wtforms.validators import DataRequired


class LoginForm(Form):
    username = TextField('username', validators=[DataRequired()])
    password = PasswordField('password', validators=[DataRequired()])
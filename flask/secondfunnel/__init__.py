from flask import Flask
from flask.ext.login import LoginManager

# Create App
from .models import User

app = Flask(__name__)

# Configure App
app.config['SECRET_KEY'] = 'yr\x1b\x90\x82]#%\xb6\xf7\x998\xa6\x96\xba\x1eg\x80\xc9\xac\xc8\x0e\xcdV'

# Login
login_manager = LoginManager()
login_manager.init_app(app)

@login_manager.user_loader
def load_user(userid):
    # This method needs to get or create a user object given an ID
    # OR, return None (no user)
    return User.get(userid)

import views
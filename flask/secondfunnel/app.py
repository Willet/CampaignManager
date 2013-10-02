import os
from flask import Flask
from .extensions import login_manager, db
from .accounts import accounts

DEFAULT_BLUEPRINTS = (
    accounts,
)

def create_app(config=None, blueprints=None):
    if blueprints is None:
        blueprints = DEFAULT_BLUEPRINTS

    app = Flask(__name__)
    configure_app(app)
    configure_blueprints(app, blueprints)
    configure_extensions(app)
    return app

def configure_app(app, config=None):
    app.config['SECRET_KEY'] = 'yr\x1b\x90\x82]#%\xb6\xf7\x998\xa6\x96\xba\x1eg\x80\xc9\xac\xc8\x0e\xcdV'

    # Flask-SQLAlchemy
    app.config['SQLALCHEMY_ECHO'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] =\
        'sqlite:///'+ app.root_path +'/db.sqlite'

def configure_blueprints(app, blueprints):
    """
    Registers all blueprints with the app

    N.B. All views should be handled via blueprints.
    """
    for blueprint in blueprints:
        app.register_blueprint(blueprint)

def configure_extensions(app):
    # Flask-SQLAlchemy
    db.init_app(app)

    # Flask-Login
    @login_manager.user_loader
    def load_user(userid):
        return None

    login_manager.init_app(app)


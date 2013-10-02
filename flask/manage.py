from flask.ext.script import Manager
from secondfunnel.models import User
from secondfunnel.extensions import db
from secondfunnel import create_app

# Effectively, manage.py
# Look at the following for some ideas:
#   https://github.com/imwilsonxu/fbone

app = create_app()
manager = Manager(app)

@manager.command
def run():
    app.run()

@manager.command
def initdb():
    db.drop_all()
    db.create_all()

    admin = User(
        username=u'admin',
        password=u'admin'
    )
    db.session.add(admin)
    db.session.commit()

manager.add_option(
    '-c',
    '--config',
    dest="config",
    required=False,
    help="config file"
)

if __name__ == "__main__":
    manager.run()
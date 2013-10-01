from flask import flash, render_template, request, url_for
from flask.ext.login import login_user, logout_user, login_required
from werkzeug.utils import redirect

from . import app
from .models import User
from .forms import LoginForm

@app.route('/')
def index():
    return render_template("index.html")

@app.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        # Validate username / password

        login_user(User('nterwoord'))

        flash("Logged in successfully.")
        return redirect(request.args.get("next") or url_for("index"))
    return render_template("login.html", form=form)

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect('')
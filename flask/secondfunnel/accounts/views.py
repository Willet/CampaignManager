from flask import Blueprint, render_template, redirect, request, flash, url_for
from flask.ext.login import login_required, login_user, logout_user
from ..models import User
from ..forms import LoginForm

accounts = Blueprint('accounts', __name__)

@accounts.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()

    if form.validate_on_submit():
        user, authenticated = User.authenticate(
            form.username.data, form.password.data
        )

        if user and authenticated:
            success = login_user(user)
            if success:
                flash('Logged in')
            return redirect('')
        else:
            flash('Sorry, invalid login')

    return render_template("login.html", form=form)

@accounts.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect('')
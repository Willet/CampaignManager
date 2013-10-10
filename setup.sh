#!/bin/sh

# echo node modules if they haven't already in their bashrc
export PATH=node_modules/.bin:${PATH}

echo "Installing SASS and COMPASS"
gem install sass compass || (echo "FAILED: verify you have latest version of NPM and Ruby installed" && exit)

echo "Installing Required Node Packages for DEV environment (package.json)"
npm install || (echo "FAIL: Couldn't install node packages, try to get 'npm install' to work" && exit)

echo "Installing Yeoman"
npm install -g yo grunt grunt-exec bower || (echo "FAIL: Couldn't install yeoman, try to get 'npm install yo' to work" && exit)

echo "Grabbing remote packages (bower.json)"
bower install || (echo "FAIL: Could not succesfully grab css/js packages. 'bower install'" && exit)

echo ""
echo "'grunt server' to run the server locally with live reload etc!"
echo "'grunt build' to compile for distribution!"
echo ""
echo "NOTE: you may need to add 'export PATH=node_modules/.bin:\$PATH{}' to your bashrc for these commands to work"


#!/bin/sh

# echo node modules if they haven't already in their bashrc
export PATH=node_modules/.bin:${PATH}

echo "Installing SASS and COMPASS"
gem install sass compass || echo "NOTE: This scripts requires NPM, and Ruby installed"

echo "Installing Required Node Packages for DEV environment (package.json)"
npm install

echo "Installing Yeoman"
npm install yo || echo "NOTE: This scripts requires NPM, and Ruby installed"

echo "Grabbing remote packages (bower.json)"
bower install

echo ""
echo "'grunt server' to run the server locally with live reload etc!"
echo "'grunt build' to compile for distribution!"
echo ""
echo "NOTE: you may need to add 'export PATH=node_modules/.bin:\$PATH{}' to your bashrc for these commands to work"


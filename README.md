# Second Funnel - Campaign Manager

Manages content and products related to pages, as well as page creation.
Will become the landing dashboard for Second Funnel.

## Technology Stack
- Yeoman (Yo + Grunt + Bower)
- SCSS, Coffeescript, Javascript
- Handlebars
- RequireJS
- Foundation Zurb
- Backbone + Marionette + StickIt + ... (check bower.json)

## Setting up your Development Environment
- Install Ruby
- Install NPM
- Run included `./setup.sh` and follow instructions

## Running Development Environment
Begin local development via `grunt server`
All assets will be live-reloaded! (javascript, css, etc...)

If you get the error `EMFILE, too many open files` or 
a similar error, type this into your terminal: `ulimit -n 20000`.
You can add it to your .bashrc or shell configuration file to make
it run every time you start a shell session.

## Deploying
- `grunt build` in order to build the `dist` folder
- dist folder can be tested via `grunt server:dist` (to verify compilation)
- copy files to DEST ...
*TODO* : We should probably upload to S3 Storage and host there most likely (or similiar)

## Mocking
- Currently requests are mocked (see `app/scripts/mock`), logging to console in the case it is mocked

## Code Layout

```
app/scripts
├── apps        # sub-regions that exist
│   ├── contentmanager
│   ├── main
│   └── pageswizard
├── components  # shared components and views between applications
│   ├── regions
│   └── views
├── config      # overrides and extensions for existing libraries
│   ├── backbone
│   └── marionette
├── dao         # App.request (ways to fetch models)
├── entities    # Backbone models
├── global      # global scripts that apply to every page
├── mock        # DEV mocking
└── views       # probably should be moved to apps/main/views
└── app.coffee  # root application
└── main.js     # initial loaded script by requireJS
```

The idea is that:
- App         - Global state held between page changes
- Routers     - Setup Controllers (and potentially Layouts)
- Views       - Trigger Events & *READ* Model, as well as modify the DOM
- Controllers - Fetch Models / Handle Models / Manipulate Models / Handle View Events


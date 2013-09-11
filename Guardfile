guard 'livereload', grace_period: 0.6 do
  watch(%r{app/views/.+\.(html)})
  watch(%r{app/assets/templates/.+\.(hbs)}) { |m| "/assets/templates/templates.pre.min.js" }
  watch(%r{app/assets/.+\.(less|css|js|scss|sass)$}) { |m| "/assets/stylesheets/app.css"}
  watch(%r{^public/.+\.(css|js|html)})
  watch(%r{conf/messages.+})
end

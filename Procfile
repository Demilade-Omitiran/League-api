web: bundle exec rails server -p ${PORT:-3000} -e $RAILS_ENV
web: rspec .
release: bundle exec rails db:migrate
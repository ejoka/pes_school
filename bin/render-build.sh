# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
# rails db:drop RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1
# rails db:create RAILS_ENV=production
bundle exec rails db:migrate
bundle exec rails db:seed
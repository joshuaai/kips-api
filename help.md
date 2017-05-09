# Help

Create the app:
```bash
rails new kips-api --api -d postgresql
```

Add the gems to the `Gemfile`:
```rb
# JWT 
gem 'jwt'
# Simple Command
gem 'simple_command'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
```

Install the gems:
```bash
bundle install
```

Generate the user:
```bash
rails g model User name:string email:string password_digest:string

rails db:migrate
```

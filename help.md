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
gem 'rack-cors', :require => 'rack/cors'
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

Add validations to `User.rb`:
```rb
# encrypt password
has_secure_password

# Validations
validates_presence_of :name, :email, :password_digest
```

## Setting Up CORS
In the `config/application.rb` add:
```rb
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource(
      '*', 
      headers: :any, 
      methods: [:get, :patch, :put, :delete, :post, :options]
    )
  end
end
```

## Encoding and Decoding with JWT
Add the `JSONWebToken` singleton class in the `lib` folder.
```rb
class JsonWebToken
  class << self
    def encode(payload, exp = 72.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
end
```

To make sure everything will work, the contents of the `lib` directory have to be included when the Rails application loads in `config/application.rb`:
```rb
#....
config.autoload_paths << Rails.root.join('lib')
#....
```

## Authenticating Users
Instead of using private controller methods, we use the `simple_command` gem.

Start by creating the folder and the `AuthenticateUser` class
```bash
mkdir app/commands

touch app/commands/authenticate_user.rb
```

In `authenticate_user.rb`, add:
```rb
class AuthenticateUser 
  prepend SimpleCommand 
  
  def initialize(email, password) 
    @email = email 
    @password = password 
  end 
  
  def call 
    JsonWebToken.encode(user_id: user.id) if user 
  end 
  
  private 
  
  attr_accessor :email, :password 
  
  def user 
    user = User.find_by_email(email) 
    return user if user && user.authenticate(password) 
    
    errors.add :user_authentication, 'invalid credentials' 
    nil 
  end 
end
```

### Checking User Authorization
Here we check if the token appended to a request is valid.

The command for authorization has to take the `headers` of the request and decode the token using the `decode` method in the `JsonWebToken` singleton.

Create the authorization class:
```bash
touch app/commands/authorize_api_request.rb
```

Add to the file:
```rb
class AuthorizeApiRequest 
  prepend SimpleCommand 
  
  def initialize(headers = {}) 
    @headers = headers 
  end 
  
  def call 
    user 
  end 
  
  private 
  
  attr_reader :headers 
  
  def user 
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token 
    @user || errors.add(:token, 'Invalid token') && nil 
  end 
  
  def decoded_auth_token 
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header) 
  end 
  
  def http_auth_header 
    if headers['Authorization'].present? 
      return headers['Authorization'].split(' ').last 
    else errors.add(:token, 'Missing token') 
    end nil 
  end 
end
```

## Implementing helper methods into the controllers
All the logic for handling JWT tokens has been laid down. We now implement it in the controllers and put use.

### Logging in users
Generate the authentication controller:
```bash
rails g controller Authentication
```

In the `authentication_controller.rb` file, add:
```rb
class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      render json: { auth_token: command.result }
    else
      render json: { error: command.errors }, status: :unauthorized
  end
end
```

In the `routes.rb` file, add:
```rb
post 'auth/login', to: 'authentication#authenticate'
```

### Authorizing Requests
To put the token to use, there must be a `current_user` method that will 'persist' the user. In order to have `current_user` available to all controllers, it has to be declared in the `ApplicationController`:
```rb
class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

end
```

### Signing up Users
In order to have users to authenticate in the first place, we need to have them signup first. This will be handled by the users controller.
```bash
rails g controller Users
```

In the `users_controller.rb` file add:
```rb
class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create
  
  # POST /signup
  # return authenticated token upon signup
  def create
    user = User.create!(user_params)
    command = AuthenticateUser.call(user.email, user.password)
    if command.success?
      response = { message: Message.account_created, auth_token: command.result }
      render json: response, status: :created
    else
      render json: { error: command.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
```

The `response` message is customized by a `Message` class added to the `lib` folder.

Add the the `routes.rb` file:
```rb
post 'signup', to: 'users#create'
```

## Scaffolding the categories and links
Now we generate the models and controllers for categories and links:
```bash
rails g scaffold Category name:string color:string user:references

rails g scaffold Link title:string link_url:string category:references
```

Add the relationship in `category.rb`:
```rb
has_many :links, dependent: :destroy
```

Add the model validations to `category.rb` and `link.rb` respectively:
```rb
validates_presence_of :name, :color
```
```rb
validates_presence_of :title, :link_url
``` 

Do the migration:
```bash
rails db:migrate
```

### Authenticating Categories with Users
In the `categories_controller.rb` file, refactor actions as follows:
```rb
# GET /categories
def index
  @categories = current_user.categories

  render json: @categories
end

# POST /categories
def create
  @category = current_user.categories.create!(category_params)

  if @category.save
    render json: @category, status: :created, location: @category
  else
    render json: @category.errors, status: :unprocessable_entity
  end
end
```

### Namespace the API for Versioning
In the routes.rb file, refactor as follows:
```rb
namespace :api do
  namespace :v1 do
    resources :categories do
      resources :links
    end
  end
end
```

Enable name spacing in `config/initializers/inflections.rb`:
```rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'API'
end
```

Version the controllers by adding the name space folder structure:
```bash
mkdir app/controllers/api

mkdir app/controllers/api/v1

mv app/controllers/categories_controller.rb app/controllers/api/v1

mv app/controllers/links_controller.rb app/controllers/api/v1
```

Add the name space the both controller files:
```rb
class API::V1::CategoriesController < ApplicationController
#...
end
```
```rb
class API::V1::LinksController < ApplicationController
#...
end
```

### Serializing the API
This will enable us get categories and links in one API call.

Add the serialization gem:
```rb
# Active model serializer
gem 'active_model_serializers', '~> 0.10.0'
```

```bash
bundle install

rails g serializer category
```

We define the serializer in `app/serializers/category_serializer.rb` with the data we want it to contain:
```rb
# attributes to be serialized
attributes :id, :name, :color, :created_at, :updated_at
# model association
has_many :links
```
This allows us to make a call as such:
```bash
http POST :3000/api/v1/categories/1/links title=me url=them Authorization:"..."
```

Refactor the scaffolded `links_controller.rb` actions to account for API serialization 
```rb
class API::V1::LinksController < ApplicationController
  before_action :set_category
  before_action :set_link, only: [:show, :update, :destroy]

  # GET /categories/:category_id/links
  def index
    render json: @category.links
  end

  # GET /links/1
  def show
    render json: @link
  end

  # POST /links
  def create
    @category.links.create!(link_params)

    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /links/1
  def update
    if @link.update(link_params)
      head :no_content
    else
      render json: @link.errors, status: :unprocessable_entity
    end
  end

  # DELETE /links/1
  def destroy
    @link.destroy
    head :no_content
  end

  private
    # Get the :category_id first
    def set_category
      @category = Category.find(params[:category_id])
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def link_params
      params.require(:link).permit(:title, :link_url, :category_id)
    end
end
```

## API Testing
Generate a Products scaffold for testing:
```bash
rails g scaffold Product name:string

rails db:migrate
```
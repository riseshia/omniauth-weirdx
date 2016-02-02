# Omniauth::WeirdX

This Gem contains the WeirdX strategy for OmniAuth.

## How to user 

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-weirdx', github: 'riseshia/omniauth-weirdx'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :weirdx, "AUTH_KEY", "AUTH_SECRET", scope: "read"
end
```

Replace `"AUTH_KEY"` and `"AUTH_SECRET"` with the appropriate values you obtained from [weirdx](not yet).

If you are using [Devise](https://github.com/plataformatec/devise) then it will look like this:

```ruby
Devise.setup do |config|
  # ...
  config.omniauth :slack, ENV["AUTH_KEY"], ENV["AUTH_SECRET"], scope: 'read'
  # ...
end
```

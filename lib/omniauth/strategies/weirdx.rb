require 'omniauth/strategies/oauth2'
require 'uri'
require 'rack/utils'

module OmniAuth
  module Strategies
    class Weirdx < OmniAuth::Strategies::OAuth2
      option :name, 'weirdx'

      option :authorize_options, [:scope]

      option :client_options, {
        site: 'http://128.199.108.141:8000',
        token_url: '/oauth2/token/',
        authorize_url: '/oauth2/authorize/'
      }

      option :auth_token_params, {
        mode: :query,
        param_name: 'token'
      }

      uid { raw_info['user_id'] }

      info do
        hash = {
          user: raw_info['user'],
          user_id: raw_info['user_id']
        }

        unless skip_info?
          hash.merge!(
            name: user_info['user'].to_h['profile'].to_h['real_name_normalized'],
            email: user_info['user'].to_h['profile'].to_h['email'],
            first_name: user_info['user'].to_h['profile'].to_h['first_name'],
            last_name: user_info['user'].to_h['profile'].to_h['last_name'],
          )
        end

        hash
      end

      extra do
        hash = {
          raw_info: raw_info
        }

        unless skip_info?
          hash.merge!(
            user_info: user_info
          )
        end

        hash
      end

      def raw_info
        @raw_info ||= access_token.get('/api/auth.test').parsed
      end

      def user_info
        url = URI.parse("/api/users.info")
        url.query = Rack::Utils.build_query(user: raw_info['user_id'])
        url = url.to_s

        @user_info ||= access_token.get(url).parsed
      end
    end
  end
end

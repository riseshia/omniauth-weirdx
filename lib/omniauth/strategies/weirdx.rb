# frozen_string_literal: true
require "omniauth/strategies/oauth2"
require "uri"
require "rack/utils"

module OmniAuth
  module Strategies
    # Strategy for Weirdx
    class Weirdx < OmniAuth::Strategies::OAuth2
      option :name, "weirdx"

      option :authorize_options, [:scope]

      option :client_options, site: "https://www.weirdx.io",
                              token_url: "/api/o/token/",
                              authorize_url: "api/o/authorize/"

      option :auth_token_params, mode: :query,
                                 param_name: "token"

      uid { raw_info["user_id"] }

      info do
        hash = {
          user: raw_info["user"],
          user_id: raw_info["user_id"]
        }

        unless skip_info?
          hash.merge!(
            name: user_info["user"].to_h["profile"]
                  .to_h["real_name_normalized"],
            email: user_info["user"].to_h["profile"].to_h["email"],
            first_name: user_info["user"].to_h["profile"].to_h["first_name"],
            last_name: user_info["user"].to_h["profile"].to_h["last_name"]
          )
        end

        hash
      end

      extra do
        hash = {
          raw_info: raw_info
        }

        hash[:user_info] = user_info unless skip_info?

        hash
      end

      def raw_info
        @raw_info ||= access_token.get("/api/auth.test").parsed
      end

      def user_info
        url = URI.parse("/api/users.info")
        url.query = Rack::Utils.build_query(user: raw_info["user_id"])
        url = url.to_s

        @user_info ||= access_token.get(url).parsed
      end
    end
  end
end

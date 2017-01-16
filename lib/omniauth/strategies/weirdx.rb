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
                              authorize_url: "/api/o/authorize/"

      option :auth_token_params, mode: :header,
                                 param_name: "token"

      uid { raw_info["id"] }

      info do
        {
          id: raw_info["id"],
          username: raw_info["username"],
          email: raw_info["email"],
          point_total: raw_info["point_total"],
          is_staff: raw_info["is_staff"],
          date_joined: raw_info["date_joined"]
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get("/api/account/info").parsed
      end

      def point_type
        url = URI.parse("/api/point_type")
        url.query = Rack::Utils.build_query(user: raw_info["id"])
        url = url.to_s

        @point_type ||= access_token.get(url).parsed
      end

      def point_list
        url = URI.parse("/api/point")
        url.query = Rack::Utils.build_query(user: raw_info["id"])
        url = url.to_s

        @point_list ||= access_token.get(url).parsed
      end
    end
  end
end

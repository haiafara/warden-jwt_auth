# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Dispatches a token (adds it to `Authorization` response header) if it
      # has been added to the request `env` by [Hooks]
      class TokenDispatcher < Middleware
        # Debugging key added to `env`
        ENV_KEY = 'warden-jwt_auth.token_dispatcher'

        attr_reader :app, :config

        def initialize(app, config = JWTAuth.config)
          @app = app
          @config = config
        end

        def call(env)
          env[ENV_KEY] = true
          status, headers, response = app.call(env)
          add_token_to_response(env, headers)
          [status, headers, response]
        end

        private

        # :reek:UtilityFunction
        def add_token_to_response(env, headers)
          token = env[Hooks::PREPARED_TOKEN_ENV_KEY]
          HeaderParser.to_headers(headers, token) if token
        end
      end
    end
  end
end

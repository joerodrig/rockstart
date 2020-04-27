# frozen_string_literal: true

# Utilities for interacting with Auth0 generated by rockstart:auth0
module Auth0Util
  class << self
    # Generates a logout redirect url
    def logout_url(redirect_to:)
      domain = ENV.fetch("AUTH0_DOMAIN")
      client_id = ENV.fetch("AUTH0_CLIENT_ID")
      request_params = {
        returnTo: redirect_to,
        client_id: client_id
      }
      URI::HTTPS.build(host: domain, path: "/v2/logout", query: to_query(request_params))
    end

    private

    def to_query(hash)
      hash.map { |k, v| "#{k}=#{CGI.escape(v)}" unless v.nil? }.reject(&:nil?).join("&")
    end
  end
end
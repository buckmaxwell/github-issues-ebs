module OmniAuthSpecHelper
  class << self
    def valid_github_login_setup
      if Rails.env.test?
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(github_response)
      end
    end

    private

    def github_response
      {
        provider: 'github',
        uid: '123545',
        info: {
          name: 'Test User'
        },
        credentials: {
          token: '123456',
          expires_at: Time.now + 1.week
        },
        repos: []
      }
    end
  end
end

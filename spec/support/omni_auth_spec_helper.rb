module OmniAuthSpecHelper
  def self.valid_github_login_setup
    if Rails.env.test?
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
        provider: 'github',
        uid: '123545',
        info: {
          name: "Test User",
        },
        credentials: {
          token: "123456",
          expires_at: Time.now + 1.week
        },
        repos: []
      })
    end
  end
end

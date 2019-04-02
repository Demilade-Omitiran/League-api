class JwtService
  class << self
    def encode(payload, context = "user")
      payload[:context] = context
      JWT.encode(payload, nil, 'none')
    end

    def decode(token)
      body = JWT.decode(token, nil, false)
      HashWithIndifferentAccess.new(body)

    rescue JWT::DecodeError, JWT::VerificationError => e
      HashWithIndifferentAccess.new(
        {
          error: true, 
          token: token, 
          message: "this token is invalid"
        }
      )
    end
  end
end
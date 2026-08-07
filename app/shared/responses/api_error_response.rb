# Builds the JSON body for every error response the API returns, so
# clients see one consistent error shape regardless of whether it came from
# a validation failure, a 404, or a domain error.
# (Laravel: App\Shared\Responses\ApiErrorResponse)
class Shared::Responses::ApiErrorResponse
  def self.body(code:, message:, details: nil)
    error = { code:, message: }
    error[:details] = details if details

    { error: }
  end
end

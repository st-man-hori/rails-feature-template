# Base class for domain/business-rule errors raised from a Feature's
# UseCases. Raise a subclass of this (per-Feature, or per-Shared concern)
# instead of a generic StandardError, so ApplicationController's rescue_from
# can render a consistent error response without knowing about every
# concrete error type. (Laravel: App\Shared\Exceptions\AppDomainException)
class Shared::Errors::AppError < StandardError
  def error_code
    raise NotImplementedError, "#{self.class} must implement #error_code"
  end

  def http_status
    raise NotImplementedError, "#{self.class} must implement #http_status"
  end
end

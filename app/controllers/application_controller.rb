# Every Feature controller inherits from this. It carries the app-wide
# error -> JSON response mapping (Laravel: the withExceptions block in
# bootstrap/app.php) so individual Feature controllers stay thin.
class ApplicationController < ActionController::API
  before_action :underscore_params!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Shared::Errors::AppError, with: :render_app_error

  private

  # The API's wire format is camelCase (isDone, dueDate) while Ruby/Rails
  # convention -- attribute names, column names -- is snake_case. Laravel
  # bridges the same gap per-Input, via a MapOutputName(SnakeCaseMapper)
  # attribute; doing it once here for every incoming request means
  # everything downstream (Requests, UseCases, Models) can just use plain
  # snake_case Ruby.
  def underscore_params!
    params.deep_transform_keys! { |key| key.to_s.underscore }
  end

  # Called by a Feature controller after `request_object.invalid?` to render
  # a 422 with field-level messages. (Laravel: FormRequest's automatic
  # ValidationException rendering)
  def render_validation_error(request_object)
    render(
      json: Shared::Responses::ApiErrorResponse.body(
        code: "validation_error",
        message: "The given data was invalid.",
        details: request_object.errors.to_hash(true),
      ),
      status: :unprocessable_content,
    )
  end

  def render_not_found
    render(
      json: Shared::Responses::ApiErrorResponse.body(
        code: "not_found",
        message: "The requested resource was not found.",
      ),
      status: :not_found,
    )
  end

  def render_app_error(error)
    render(
      json: Shared::Responses::ApiErrorResponse.body(code: error.error_code, message: error.message),
      status: error.http_status,
    )
  end
end

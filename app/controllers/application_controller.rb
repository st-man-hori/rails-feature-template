# すべての Feature コントローラはこれを継承する。アプリ全体のエラー →
# JSON レスポンス変換をここに集約しているので(Laravel でいう
# bootstrap/app.php の withExceptions ブロックに相当)、個々の Feature
# コントローラは薄いままでいられる。
class ApplicationController < ActionController::API
  before_action :underscore_params!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Shared::Errors::AppError, with: :render_app_error

  private

  # API の wire フォーマットは camelCase(isDone, dueDate)だが、
  # Ruby/Rails の慣習(属性名・カラム名)は snake_case。Laravel は
  # Input ごとに MapOutputName(SnakeCaseMapper)属性でこのギャップを
  # 埋めているが、ここでは受信リクエストに対して一箇所でまとめて変換する
  # ことで、以降(Requests・UseCases・Models)はすべて素の snake_case な
  # Ruby として書けるようにしている。
  def underscore_params!
    params.deep_transform_keys! { |key| key.to_s.underscore }
  end

  # Feature コントローラが `request_object.invalid?` の後に呼び出し、
  # フィールドごとのメッセージ付きで 422 を返す。
  # (Laravel: FormRequest によるバリデーション失敗時の自動レンダリング)
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

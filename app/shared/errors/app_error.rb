# Feature の UseCase から送出する、ドメイン/ビジネスルール由来のエラーの
# 基底クラス。汎用的な StandardError ではなく、この継承クラス(Feature
# ごと、あるいは Shared の関心事ごと)を送出することで、
# ApplicationController の rescue_from が個々の具象エラー型を知らなくても
# 一貫したエラーレスポンスを返せるようになる。
# (Laravel: App\Shared\Exceptions\AppDomainException)
class Shared::Errors::AppError < StandardError
  def error_code
    raise NotImplementedError, "#{self.class} must implement #error_code"
  end

  def http_status
    raise NotImplementedError, "#{self.class} must implement #http_status"
  end
end

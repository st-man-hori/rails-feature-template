# API が返すすべてのエラーレスポンスの JSON ボディを組み立てる。バリデー
# ションエラー・404・ドメインエラーのどれが原因でも、クライアントから見
# えるエラーの形を一貫させるため。
# (Laravel: App\Shared\Responses\ApiErrorResponse)
class Shared::Responses::ApiErrorResponse
  def self.body(code:, message:, details: nil)
    error = { code:, message: }
    error[:details] = details if details

    { error: }
  end
end

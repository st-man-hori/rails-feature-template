# クエリパラメータを検証し、Input に変換する。ActiveModel::Model +
# ActiveModel::Attributes(どちらも Rails 標準で追加 gem 不要)が、
# Laravel の FormRequest と同じ役割を果たす -- 型付き属性・`validates`・
# UseCase に渡す前にコントローラが呼ぶ `valid?` という組み合わせ。
class Features::Task::Requests::IndexTaskRequest
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :is_done, :boolean
  attribute :per_page, :integer, default: 15
  attribute :page, :integer, default: 1

  validates :per_page, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :page, numericality: { only_integer: true, greater_than: 0 }

  def to_input
    Features::Task::Inputs::IndexTaskInput.new(is_done:, per_page:, page:)
  end
end

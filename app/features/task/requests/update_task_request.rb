# PATCH はクライアントが実際に送ってきたフィールドだけを更新し、それ以外
# には触れないのが正しい挙動。Laravel の Optional ラッパー(や Go 版の
# ジェネリックな Field[T])は、まさにこの区別のためだけに存在する --
# PHP/Go の構造体は「キーが無い」と「キーはあるが null」を素の型では
# 区別できないから。Ruby の素の Hash はそもそもこれを区別できる:
# `permitted_params.keys` にはクライアントが実際に送ったキーしか入らない
# (ActionController::Parameters はリクエストに無いキーを落とす。Laravel
# の `sometimes` ルールと同じ挙動)ので、下の `to_input` は属性一式を
# そのキー集合で絞り込むだけでよく、専用の型は不要になる。
class Features::Task::Requests::UpdateTaskRequest
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :description, :string
  attribute :due_date, :date
  attribute :is_done, :boolean

  validates :title, presence: true, length: { maximum: 255 }, allow_nil: true
  validates :description, length: { maximum: 65_535 }, allow_nil: true

  def initialize(permitted_params)
    @provided_keys = permitted_params.keys.map(&:to_sym)
    super(permitted_params)
  end

  def to_input
    attributes.symbolize_keys.slice(*@provided_keys)
  end
end

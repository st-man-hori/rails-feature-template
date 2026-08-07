# Validates query params and converts them into an Input. ActiveModel::Model
# + ActiveModel::Attributes (both built into Rails, no extra gem) fill the
# same role as a Laravel FormRequest: typed attributes, `validates`, and a
# `valid?` check the controller runs before touching a UseCase.
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

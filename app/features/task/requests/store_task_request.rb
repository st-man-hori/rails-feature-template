class Features::Task::Requests::StoreTaskRequest
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :description, :string
  attribute :due_date, :date

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 65_535 }, allow_nil: true

  def to_input
    Features::Task::Inputs::StoreTaskInput.new(title:, description:, due_date:)
  end
end

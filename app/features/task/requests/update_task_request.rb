# A PATCH should only touch the fields the client actually sent, leaving
# everything else alone -- Laravel's Optional wrapper (and the Go version's
# generic Field[T]) exist purely to make that distinction, since PHP/Go
# structs can't otherwise tell "key absent" apart from "key present but
# null". A plain Ruby Hash already can: `permitted_params.keys` only
# contains keys the client actually sent (ActionController::Parameters
# drops anything absent from the request the same way Laravel's `sometimes`
# rule does), so `to_input` below just slices the full attribute set down
# to those keys -- no extra type needed.
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

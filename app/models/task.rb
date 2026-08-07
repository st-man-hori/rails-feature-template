# Sample Feature's model. Deliberately carries no validations -- validation
# lives entirely in Features::Task::Requests so the same
# Controller -> Request -> Input -> UseCase -> Model -> Resource pipeline
# the Laravel version uses stays intact. (Laravel: App\Models\Task)
class Task < ApplicationRecord
end

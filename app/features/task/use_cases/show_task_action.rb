# Task.find raises ActiveRecord::RecordNotFound when missing, which
# ApplicationController's rescue_from turns into a 404. (Laravel:
# Task::query()->findOrFail($taskId))
class Features::Task::UseCases::ShowTaskAction
  def call(task_id)
    Task.find(task_id)
  end
end

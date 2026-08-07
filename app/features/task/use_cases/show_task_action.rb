# Task.find は見つからない場合に ActiveRecord::RecordNotFound を送出し、
# それを ApplicationController の rescue_from が 404 に変換する。
# (Laravel: Task::query()->findOrFail($taskId))
class Features::Task::UseCases::ShowTaskAction
  def call(task_id)
    Task.find(task_id)
  end
end

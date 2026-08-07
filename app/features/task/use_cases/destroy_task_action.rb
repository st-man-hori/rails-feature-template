class Features::Task::UseCases::DestroyTaskAction
  def call(task_id)
    Task.find(task_id).destroy!
  end
end

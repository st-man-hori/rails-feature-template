class Features::Task::UseCases::UpdateTaskAction
  def call(task_id, attributes)
    task = Task.find(task_id)
    task.update!(attributes)
    task
  end
end

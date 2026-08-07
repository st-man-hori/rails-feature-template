# Shapes a Task (or a collection of them) into the API's camelCase response
# format. Plain class methods rather than an instantiated object, since
# there's no per-instance state to carry -- the whole point is decoupling
# the wire format from the model's column names.
# (Laravel: App\Features\Task\Resources\TaskResource)
class Features::Task::Resources::TaskResource
  def self.to_h(task)
    {
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.due_date&.iso8601,
      isDone: task.is_done,
      createdAt: task.created_at&.iso8601,
      updatedAt: task.updated_at&.iso8601
    }
  end

  def self.collection(tasks)
    tasks.map { |task| to_h(task) }
  end
end

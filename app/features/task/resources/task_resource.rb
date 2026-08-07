# Task(またはその集合)を API の camelCase レスポンス形式に変換する。
# インスタンス化せずクラスメソッドだけで完結させているのは、保持すべき
# インスタンス状態が無いから -- 目的はあくまで wire フォーマットを
# モデルのカラム名から切り離すことにある。
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

class Features::Task::UseCases::StoreTaskAction
  def call(input)
    Task.create!(title: input.title, description: input.description, due_date: input.due_date)
  end
end

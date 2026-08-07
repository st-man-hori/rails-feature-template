class Features::Task::UseCases::IndexTaskAction
  def call(input)
    scope = Task.all
    scope = scope.where(is_done: input.is_done) unless input.is_done.nil?
    scope = scope.order(created_at: :desc)

    total = scope.count
    tasks = scope.offset((input.page - 1) * input.per_page).limit(input.per_page)

    [ tasks, total ]
  end
end

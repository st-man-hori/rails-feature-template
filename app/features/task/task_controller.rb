# Sample Feature: everything needed to serve /api/tasks lives in this
# directory. Copy this Feature as a starting point for a new one, then
# delete it once your first real Feature exists.
#
# Request flow: Router -> ApplicationController#underscore_params! ->
# TaskController -> Request (validate) -> Input -> UseCase -> Model ->
# Resource. (Laravel: Router -> Middleware -> Controller -> FormRequest ->
# Input DTO -> UseCase -> Model -> Resource)
class Features::Task::TaskController < ApplicationController
  def index
    request = Features::Task::Requests::IndexTaskRequest.new(index_params)
    return render_validation_error(request) if request.invalid?

    tasks, total = Features::Task::UseCases::IndexTaskAction.new.call(request.to_input)

    render json: {
      data: Features::Task::Resources::TaskResource.collection(tasks),
      meta: {
        total:,
        page: request.page,
        perPage: request.per_page,
        totalPages: (total.to_f / request.per_page).ceil
      }
    }
  end

  def show
    task = Features::Task::UseCases::ShowTaskAction.new.call(params[:id])

    render json: { data: Features::Task::Resources::TaskResource.to_h(task) }
  end

  def create
    request = Features::Task::Requests::StoreTaskRequest.new(store_params)
    return render_validation_error(request) if request.invalid?

    task = Features::Task::UseCases::StoreTaskAction.new.call(request.to_input)

    render json: { data: Features::Task::Resources::TaskResource.to_h(task) }, status: :created
  end

  def update
    request = Features::Task::Requests::UpdateTaskRequest.new(update_params)
    return render_validation_error(request) if request.invalid?

    task = Features::Task::UseCases::UpdateTaskAction.new.call(params[:id], request.to_input)

    render json: { data: Features::Task::Resources::TaskResource.to_h(task) }
  end

  def destroy
    Features::Task::UseCases::DestroyTaskAction.new.call(params[:id])

    head :no_content
  end

  private

  def index_params
    params.permit(:is_done, :per_page, :page)
  end

  def store_params
    params.permit(:title, :description, :due_date)
  end

  def update_params
    params.permit(:title, :description, :due_date, :is_done)
  end
end

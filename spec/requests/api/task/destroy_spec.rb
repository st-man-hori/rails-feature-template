require "rails_helper"

RSpec.describe "DELETE /api/tasks/:id", type: :request do
  it "deletes a task" do
    task = create(:task)

    delete "/api/tasks/#{task.id}"

    expect(response).to have_http_status(:no_content)
    expect(Task.exists?(task.id)).to be false
  end

  it "returns 404 when the task does not exist" do
    delete "/api/tasks/999"

    expect(response).to have_http_status(:not_found)
  end
end

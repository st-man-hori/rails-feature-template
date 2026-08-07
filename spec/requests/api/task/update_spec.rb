require "rails_helper"

RSpec.describe "PATCH /api/tasks/:id", type: :request do
  it "updates only the given fields" do
    task = create(:task, title: "Original title", description: "Original description", is_done: false)

    patch "/api/tasks/#{task.id}", params: { isDone: true }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to include("title" => "Original title", "isDone" => true)

    task.reload
    expect(task.is_done).to eq(true)
    expect(task.title).to eq("Original title")
  end

  it "returns 404 when the task does not exist" do
    patch "/api/tasks/999", params: { title: "Anything" }, as: :json

    expect(response).to have_http_status(:not_found)
  end
end

require "rails_helper"

RSpec.describe "GET /api/tasks", type: :request do
  it "returns a paginated list of tasks" do
    create_list(:task, 3)

    get "/api/tasks"

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["data"].size).to eq(3)
    expect(body["data"].first.keys).to contain_exactly(
      "id", "title", "description", "dueDate", "isDone", "createdAt", "updatedAt"
    )
  end

  it "filters tasks by isDone" do
    create_list(:task, 2, is_done: false)
    create(:task, :done)

    get "/api/tasks", params: { isDone: true }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"].size).to eq(1)
  end
end

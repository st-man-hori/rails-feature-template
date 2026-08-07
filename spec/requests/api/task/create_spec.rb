require "rails_helper"

RSpec.describe "POST /api/tasks", type: :request do
  it "creates a task" do
    payload = {
      title: "Write the quarterly report",
      description: "Summarize Q2 sales figures",
      dueDate: "2026-08-01"
    }

    post "/api/tasks", params: payload, as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["data"]).to include(
      "title" => "Write the quarterly report",
      "description" => "Summarize Q2 sales figures",
      "dueDate" => "2026-08-01",
      "isDone" => false,
    )

    task = Task.sole
    expect(task.title).to eq("Write the quarterly report")
    expect(task.due_date.iso8601).to eq("2026-08-01")
  end

  it "requires a title" do
    post "/api/tasks", params: { description: "No title given" }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.dig("error", "details")).to have_key("title")
    expect(Task.count).to eq(0)
  end
end

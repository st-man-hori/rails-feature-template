# サンプル Feature のモデル。あえてバリデーションを持たせていない --
# バリデーションは Features::Task::Requests 側に集約し、Laravel 版と同じ
# Controller → Request → Input → UseCase → Model → Resource という
# 流れを保っている。(Laravel: App\Models\Task)
class Task < ApplicationRecord
end

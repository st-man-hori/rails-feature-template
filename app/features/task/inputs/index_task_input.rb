# Request が UseCase に渡す、不変の値オブジェクト。Ruby 標準の
# Data.define(3.2 以降)が、Laravel 版の spatie/laravel-data の Data
# クラスと同じ役割を果たす -- 追加の gem なしで、キーワード引数から作れる
# 不変の構造体が手に入る。
Features::Task::Inputs::IndexTaskInput = Data.define(:is_done, :per_page, :page)

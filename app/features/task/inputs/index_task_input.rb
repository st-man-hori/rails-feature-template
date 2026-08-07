# Immutable value object the Request hands to the UseCase. Ruby's built-in
# Data.define (3.2+) fills the same role as spatie/laravel-data's Data class
# in the Laravel version -- an immutable, keyword-constructed struct with no
# extra gem required.
Features::Task::Inputs::IndexTaskInput = Data.define(:is_done, :per_page, :page)

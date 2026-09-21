Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      get "categories", to: "categories#index"

      namespace :auth do
        post "register", to: "registrations#create"
        post "login", to: "sessions#create"
        post "refresh", to: "sessions#refresh"
        delete "logout", to: "sessions#destroy"
        get "me", to: "me#show"
        post "forgot_password", to: "passwords#forgot"
        post "reset_password", to: "passwords#reset"
      end

      namespace :admin do
        resources :users, param: :uuid, only: %i[index]
        resources :categories, param: :uuid, only: %i[index show create update destroy]
        resources :quizzes, param: :uuid, only: %i[index show] do
          member do
            get :statistics
          end
        end
        resources :courses, param: :uuid, only: %i[index show create update destroy] do
          member do
            post "instructors", to: "courses#assign_instructor"
            delete "instructors/:user_uuid", to: "courses#remove_instructor"
            post :publish, to: "courses#publish"
            post :unpublish, to: "courses#unpublish"
            post :archive, to: "courses#archive"
          end
        end
        resources :enrollments, param: :uuid, only: %i[index show create destroy]
        resources :certificates, param: :uuid, only: %i[index show] do
          member do
            post :revoke
          end
        end
        resources :announcements, param: :uuid, only: %i[index show create update destroy] do
          member do
            post :publish
          end
        end
        resources :reviews, param: :uuid, only: %i[index show destroy]
        namespace :reports do
          get :dashboard
          get :enrollments
          get :course_completion
        end
        resources :audit_logs, param: :uuid, only: %i[index show]
      end

      namespace :instructor do
        get :dashboard, to: "dashboard#show"
        resources :courses, param: :uuid, only: %i[index show create update] do
          member do
            post :publish, to: "courses#publish"
            post :unpublish, to: "courses#unpublish"
            get :enrollments, to: "enrollments#index"
          end
          resources :modules, param: :uuid, only: %i[index create], controller: "modules" do
            collection do
              patch :reorder, to: "modules#reorder"
            end
          end
          resources :quizzes, param: :uuid, only: %i[index create], controller: "quizzes"
          resources :assignments, param: :uuid, only: %i[index create], controller: "assignments"
          resources :announcements, param: :uuid, only: %i[index create], controller: "announcements"
        end
        resources :modules, param: :uuid, only: %i[update destroy], controller: "modules" do
          resources :lessons, param: :uuid, only: %i[index create], controller: "lessons" do
            collection do
              patch :reorder, to: "lessons#reorder"
            end
          end
        end
        resources :lessons, param: :uuid, only: %i[update destroy], controller: "lessons" do
          resources :resources, param: :uuid, only: %i[create], controller: "lesson_resources"
          resources :quizzes, param: :uuid, only: %i[index create], controller: "quizzes"
          resources :assignments, param: :uuid, only: %i[index create], controller: "assignments"
        end
        resources :quizzes, param: :uuid, only: %i[show update destroy], controller: "quizzes" do
          member do
            post :publish
            post :unpublish
            get :attempts
          end
          resources :questions, param: :uuid, only: %i[index create], controller: "questions" do
            collection do
              patch :reorder, to: "questions#reorder"
            end
          end
        end
        resources :questions, param: :uuid, only: %i[update destroy], controller: "questions" do
          resources :options, param: :uuid, only: %i[create], controller: "question_options"
        end
        resources :options, param: :uuid, only: %i[update destroy], controller: "question_options"
        resources :assignments, param: :uuid, only: %i[show update destroy], controller: "assignments" do
          member do
            post :publish
            post :unpublish
            get :submissions
          end
        end
        resources :submissions, param: :uuid, only: [], controller: "submissions" do
          collection do
            get :pending
          end
          member do
            patch :grade
          end
        end
        resources :announcements, param: :uuid, only: %i[show update destroy], controller: "announcements" do
          member do
            post :publish
          end
        end
        resources :enrollments, param: :uuid, only: [], controller: "enrollments" do
          member do
            get :progress
          end
        end
      end

      namespace :student do
        get :dashboard, to: "dashboard#show"
        resources :courses, param: :uuid, only: %i[index show] do
          member do
            post "enroll", to: "courses#enroll"
            get :reviews, to: "reviews#index"
            post :reviews, to: "reviews#create"
          end
        end
        resources :reviews, param: :uuid, only: %i[update destroy], controller: "reviews"
        resources :enrollments, param: :uuid, only: %i[index show] do
          member do
            get "lessons/:lesson_uuid", to: "enrollments#lesson_progress"
            patch "lessons/:lesson_uuid/progress", to: "enrollments#update_lesson_progress"
            post "lessons/:lesson_uuid/complete", to: "enrollments#complete_lesson"
            get "resources/:resource_uuid/download", to: "lesson_resources#download"
            get :quizzes, to: "quizzes#index"
            get "quizzes/:quiz_uuid", to: "quizzes#show"
            post "quizzes/:quiz_uuid/start", to: "quizzes#start"
            get :assignments, to: "assignments#index"
            get "assignments/:assignment_uuid", to: "assignments#show"
            post "assignments/:assignment_uuid/submit", to: "assignments#submit"
          end
        end
        resources :quiz_attempts, param: :uuid, only: %i[show], controller: "quiz_attempts" do
          member do
            patch :responses, to: "quiz_attempts#save_responses"
            post :submit, to: "quiz_attempts#submit"
            get :results, to: "quiz_attempts#results"
          end
        end
        resources :certificates, param: :uuid, only: %i[index show]
        resources :notifications, param: :uuid, only: %i[index show] do
          collection do
            get :unread_count
            post :read_all
          end
          member do
            patch :read
          end
        end
        resources :announcements, param: :uuid, only: %i[index]
      end
    end
  end
end

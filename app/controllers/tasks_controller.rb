class TasksController < ApplicationController
  def index
    @tasks = current_account.tasks.by_deadline
  end

  def create
    @task = current_account.tasks.create!(position: (current_account.tasks.maximum(:position) || -1) + 1)
  end

  def update
    @task = current_account.tasks.find(params[:id])
    @task.update!(params.require(:task).permit(:category, :body, :due_on, :done))
    head :no_content
  end

  def destroy
    @task = current_account.tasks.find(params[:id])
    @task.destroy
  end
end

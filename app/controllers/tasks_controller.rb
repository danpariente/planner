class TasksController < ApplicationController
  def index
    @tasks = Task.by_deadline
  end

  def create
    @task = Task.create!(position: (Task.maximum(:position) || -1) + 1)
  end

  def update
    @task = Task.find(params[:id])
    @task.update!(params.require(:task).permit(:category, :body, :due_on, :done))
    head :no_content
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
  end
end
